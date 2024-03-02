import SwiftUI



struct TaskList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name),
    ]) var exercises: FetchedResults<Exercise>
    
    @FocusState private var nameIsFocused: Bool
    @State var showAlert = false
    @State var name: String = ""
    //    @State var text: String = ""
    let maxCharacters: Int = 20
    
    var body: some View {
        
        NavigationStack {
            
            ZStack(alignment: .top) {
                CustomColor.background
                    .ignoresSafeArea()
                VStack() {
                    Text("Create New Task")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(CustomColor.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    AddTask()
                    Divider()
                        .padding(.top,15)
                        .padding(.bottom,10)
                    
                    Text("Saved Tasks")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(CustomColor.day)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    SavedTasks()
                }
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            .alert("Please enter a name for the task", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
            
        }
        .tint(CustomColor.highlight)
    }
    
    @ViewBuilder
    func SavedTasks() -> some View {
    if exercises.count < 1 {
        Text("No tasks have been saved yet")
            .font(.system(size: 20))
            .foregroundColor(CustomColor.muted)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 50)
    } else {
        List {
            ForEach(exercises) { exercise in
                VStack {
                    Text(exercise.name ?? "Not found")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .listRowBackground(CustomColor.highlight)
            }
            .onDelete(perform: deleteItem)
        }
        .scrollContentBackground(.hidden)
    }
}
    
    @ViewBuilder
    func AddTask() -> some View {
    HStack() {
        TextField("", text: $name.max(maxCharacters))
            .font(.system(size: 18))
            .focused($nameIsFocused)
            .modifier(TextFieldClearButton(text: $name))
            .multilineTextAlignment(.leading)
            .textFieldStyle(.plain)
            .padding(.horizontal,15)
            .padding(.vertical, 10)
            .cornerRadius(5)
            .background(
                ZStack {
                    CustomColor.lightBackground
                    if (name.count == 0) {
                    HStack {
                            Text("Enter task name...")
                                .foregroundColor(CustomColor.muted)
                                .padding(.horizontal, 15)
                            Spacer()
                        }
                    }
                }
            )
            .onSubmit {
                addTask()
            }
            .submitLabel(.go)
            .foregroundColor(CustomColor.highlight)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        if nameIsFocused == true {
            Button("Cancel") {
                name = ""
                nameIsFocused = false
            }
        }
    }
    
    
    Text("Characters Remaining: \(maxCharacters - name.count)")
        .font(.system(size: 14))
        .foregroundColor(CustomColor.muted)
        .frame(maxWidth: .infinity, alignment: .leading)
}
    
    private func addTask() {
        withAnimation {
            if (name.count < 2) {
                showAlert = true
                
            } else {
                nameIsFocused = false
                let exercise = Exercise(context: viewContext)
                exercise.name = name
                //              exercise.text = text
                exercise.text = ""
                exercise.isUsed = false
                exercise.id = UUID()
                exercise.day = ""
                name = ""
                //              text = ""
                PersistenceController.shared.saveCoreData()
            }
        }
    }
    
    private func deleteItem(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let exercise = exercises[index]
                viewContext.delete(exercise)
            }
            PersistenceController.shared.saveCoreData()
        }
    }
    
    struct TaskList_Previews: PreviewProvider {
        static var previews: some View {
            TaskList()
        }
    }
    
}
