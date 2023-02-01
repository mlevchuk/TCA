//
//  TestView.swift
//  TCATest
//
//  Created by Mykhaylo Levchuk on 31/01/2023.
//

import SwiftUI
import ComposableArchitecture
import _SwiftUINavigationState

struct SearchFeature: ReducerProtocol {
    struct State: Equatable {
        var name: String
        var isValid: Bool { name.count > 5 }
        
        var fetchedPerson: Person?
        var alert: AlertState<Action>?
    }
    
    enum Action: Equatable {
        case textChanged(text: String)
        case searchButtonTapped
        case personFetched(TaskResult<Person>)
        case alertOkTapped
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
            case .textChanged(let text):
                state.name = text
                return .none
            case .searchButtonTapped:
                return .task { [query = state.name] in
                    await .personFetched(
                        TaskResult {
                            let (data, _) = try await URLSession.shared.data(from: URL(string: "https://api.agify.io/?name=\(query)")!, delegate: nil)
                            return try JSONDecoder().decode(Person.self, from: data)
                        }
                    )
                }
            case .personFetched(.success(let person)):
                state.fetchedPerson = person
                return .none
            case .personFetched(.failure):
                state.fetchedPerson = nil
                state.alert = AlertState<SearchFeature.Action>.init(
                    title: { TextState("Alert") },
                    actions: {
                        ButtonState(label: { TextState("OK") })
                    }, message: nil)
                return .none
            case .alertOkTapped:
                state.alert = nil
                return .none
        }
    }
}


struct TestView: View {
    let store: StoreOf<SearchFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 15) {
                VStack {
                    Text("Name: \(viewStore.fetchedPerson?.name ?? "")")
                    if let age = viewStore.fetchedPerson?.age {
                        Text("Age: \(age)")
                    } else {
                        Text("Age: ")
                    }
                }
                
                TextField("Name", text: viewStore.binding(
                    get: { $0.name },
                    send: SearchFeature.Action.textChanged
                ))
                .frame(width: 300, height: 45)
                .padding(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(viewStore.isValid ? Color.green : Color.red)
                )
                
                Button(
                    action: { viewStore.send(.searchButtonTapped) },
                    label: { Text("Search Person") }
                )
                .frame(width: 200, height: 45)
                .padding(5)
                .background(Color.green)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.purple))
                .background(Color.white)
                .cornerRadius(20)
                .foregroundColor(Color.white)
                
            }
            .alert(store.scope(state: \.alert), dismiss: .alertOkTapped)
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView(store: .init(initialState: SearchFeature.State.init(name: ""), reducer: SearchFeature()))
    }
}
