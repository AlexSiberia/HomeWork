/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct TubeStatusView: View {
  @ObservedObject private(set) var model: TubeStatusViewModel

  let titleText: String

  init(model: TubeStatusViewModel) {
    UINavigationBar.appearance().tintColor = UIColor(Color.tflBlue)

    self.model = model

    titleText = "Tube Status"
  }

  func loadData() {
    model.perform(action: .fetchCurrentStatus)
  }

  var body: some View {
    NavigationView {
      ZStack {
        Color(UIColor.systemGroupedBackground)
          .edgesIgnoringSafeArea(.all)
        Loadable(loadingState: model.tubeStatusState, hideContentWhenLoading: true) { tubeStatus in
          if tubeStatus.linesStatus.isEmpty {
            Text("Unexpected Error: No status to show")
          } else {
            ScrollView {
              LazyVStack(spacing: 0) {
                ForEach(tubeStatus.linesStatus) { lineStatus in
                  LineStatusRow(
                    lineDisplayName: lineStatus.displayName,
                    status: lineStatus.status,
                    lineColor: lineStatus.color
                  )
                }
                //1
                HStack {
                  //2
                  Image(systemName: "clock.badge.checkmark")
                    .imageScale(.large)
                    .padding()
                    .font(Font.title2.weight(.regular))
                    .symbolVariant(.fill)
                    //3
                    .symbolRenderingMode(.palette)
                    //4
                    .foregroundStyle(Color(uiColor: .systemGreen), Color(uiColor: .label))
                  Text("\(tubeStatus.lastUpdated)")
                    .font(.footnote)
                    .padding()
                }

              }
            }
          }
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(titleText)
        }
      }
      .navigationBarItems(
        trailing:
          Button(action: {
            loadData()
          }, label: {
//            Text("Refresh")
            //1
            HStack(spacing: 10) {
              //2
              Image(systemName: "arrow.triangle.2.circlepath")
              Text("Refresh")
            }

          })
      )
      .onAppear(perform: loadData)
    }
  }
}


struct TubeStatusView_Previews: PreviewProvider {
  static var previews: some View {
    let viewModel = TubeStatusViewModel(tubeLinesStatusFetcher: DebugDataService())
    TubeStatusView(model: viewModel)
  }
}
