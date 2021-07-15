//
//  Home.swift
//  HalfSheetModal
//
//  Created by Maxim Macari on 16/7/21.
//

import SwiftUI

struct Home: View {
    
    @State var showSheet: Bool = false
    
    var body: some View {
        NavigationView{
            Button(action: {
                showSheet.toggle()
            }, label: {
                Text("Present sheet")
            })
            .navigationTitle("Half Modal Sheet")
            .halfSheet(showSheet: $showSheet) {
                ZStack {
                    
                    Color.red
                    
                    VStack {
                        Text("Hello There!!")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        
                        Button(action: {
                            showSheet.toggle()
                        }, label: {
                            Text("CLose from sheet")
                                .foregroundColor(.white)
                        })
                        .padding()
                    }
                }
                .ignoresSafeArea()
            } onEnd: {
                print("Dismissed")
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

//extension half sheet modifier
extension View {
    func halfSheet<SheetView: View>(showSheet: Binding<Bool>, @ViewBuilder sheetView: @escaping ()-> SheetView, onEnd: @eescaping ()->())-> some View {
        
        //overelay -> will automatically use thee swiftui frame size only..
        
        return self
            .overlay(
                HalfSheetHelper(sheetView: sheetView(), showSheet: showSheet, onEnd: onEnd)
            )
    }
}

//Ukit integration
struct HalfSheetHelper<SheetView: View>: UIViewControllerRepresentable {
    var sheetView: SheetView
    @Binding var showSheet: Bool
    var onEnd: () -> ()
    let controller = UIViewController()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        controller.view.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if showSheet {
            
            //presenting modal...
            
            let sheetController = UIHostingController(rootView: sheetView)
            sheetController.presentationController?.delegate = context.coordinator
            uiViewController.present(sheetController, animated: true)
        } else {
            // closing view when showSheet toggled again
            uiViewController.dismiss(animated: true)
        }
    }
    // on dismiss
    class Coordinator: NSObject, UISheetPresentationControllereDelegate {
        var parent: HalfSheetHelper
        
        init(parent: HalfSheetHelper) {
            self.parent = parent
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.showSheet = false
            pareent.onEnd()
        }
    }
}

//Custom UIHostingController for halfsheet
class CustomHostingController<Content: View>: UIHostingController<Content>{
    override func viewDidLoad() {
        view.backgroundColor = .clear
        //setting the presentation controller properties
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [
                .medium(),
                .large()
            ]
            
            //to show grab position
            presentationController.prefersGrabberVisible = true
            
        }
    }
}
