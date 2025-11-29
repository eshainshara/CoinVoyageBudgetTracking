import SwiftUI
import WebKit
import UIKit

struct BrowserScreen: View {
    @StateObject private var viewModel = BrowserViewModel()
    
    var body: some View {
        BrowserOrientationWrapper(viewModel: viewModel)
            .ignoresSafeArea()
            .statusBarHidden(true)
    }
}

struct BrowserOrientationWrapper: UIViewControllerRepresentable {
    let viewModel: BrowserViewModel
    
    func makeUIViewController(context: Context) -> BrowserOrientationViewController {
        return BrowserOrientationViewController(viewModel: viewModel)
    }
    
    func updateUIViewController(_ uiViewController: BrowserOrientationViewController, context: Context) {
        uiViewController.setNeedsStatusBarAppearanceUpdate()
    }
}

class BrowserOrientationViewController: UIViewController {
    private let viewModel: BrowserViewModel
    private var hostingController: UIHostingController<BrowserContent>!
    
    init(viewModel: BrowserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hostingController = UIHostingController(rootView: BrowserContent(viewModel: viewModel))
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return nil
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return nil
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        setNeedsStatusBarAppearanceUpdate()
        AppDelegate.orientationLock = .all
        if #available(iOS 16.0, *) {
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.orientationLock = .portrait
        if #available(iOS 16.0, *) {
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
            if let windowScene = self.view.window?.windowScene {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
}

struct BrowserContent: View {
    @ObservedObject var viewModel: BrowserViewModel
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
            
            if !viewModel.currentAddress.isEmpty {
                BrowserContainer(address: viewModel.currentAddress, viewModel: viewModel)
                    .opacity(viewModel.isLoading ? 0 : 1)
                    .ignoresSafeArea(.all)
            }
        }
        .statusBar(hidden: true)
        .onAppear {
            viewModel.loadPage()
        }
    }
}

struct BrowserContainer: UIViewRepresentable {
    let address: String
    @ObservedObject var viewModel: BrowserViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let browserView = WKWebView(frame: .zero, configuration: configuration)
        browserView.navigationDelegate = context.coordinator
        browserView.scrollView.contentInsetAdjustmentBehavior = .never
        browserView.scrollView.contentInset = .zero
        browserView.scrollView.scrollIndicatorInsets = .zero
        browserView.scrollView.bounces = false
        browserView.allowsBackForwardNavigationGestures = true
        if let destination = URL(string: address) {
            let request = URLRequest(url: destination)
            browserView.load(request)
        }
        return browserView
    }
    
    func updateUIView(_ browserView: WKWebView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let viewModel: BrowserViewModel
        
        init(viewModel: BrowserViewModel) {
            self.viewModel = viewModel
        }
        
        func webView(_ browserView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            if !viewModel.hasLoadedInitially {
                viewModel.didStartNavigation()
            }
        }
        
        func webView(_ browserView: WKWebView, didFinish navigation: WKNavigation!) {
            if !viewModel.hasLoadedInitially {
                viewModel.didFinishInitialLoad()
            }
        }
        
        func webView(_ browserView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            if !viewModel.hasLoadedInitially {
                viewModel.didFinishInitialLoad()
            }
        }
    }
}

