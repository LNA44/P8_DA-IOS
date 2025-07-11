//
//  AddExerciseView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct AddExerciseView: View {
	@Environment(\.presentationMode) var presentationMode
	@ObservedObject var viewModel: AddExerciseViewModel
	
	var body: some View {
		NavigationView {
			VStack {
				Form {
					TextField("Catégorie", text: $viewModel.category)
					TextField("Heure de démarrage", text: $viewModel.startTimeString)
					TextField("Durée (en minutes)", text: $viewModel.durationString)
					TextField("Intensité (0 à 10)", text: $viewModel.intensityString)
				}.formStyle(.grouped)
				Spacer()
				Button("Ajouter l'exercice") {
					if viewModel.errorMessage==nil {
						viewModel.addExercise()
						presentationMode.wrappedValue.dismiss()
					}
				}.buttonStyle(.borderedProminent)
				
			}
			.navigationTitle("Nouvel Exercice ...")
		}
		.alert(isPresented: $viewModel.showAlert) {
			Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
		}
	}
}

#Preview {
	AddExerciseView(viewModel: AddExerciseViewModel())
}
