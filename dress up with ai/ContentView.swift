
//
//  ContentView.swift
//  dress up with ai
//
//  Created by paulprakash ladarla on 26/09/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            WardrobeView()
                .tabItem {
                    Label("Wardrobe", systemImage: "hanger")
                }
            
            SuggestionsView()
                .tabItem {
                    Label("Suggestions", systemImage: "lightbulb")
                }
        }
    }
}

struct WardrobeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingImagePicker = false
    @State private var showingCategorySheet = false
    @State private var inputImage: UIImage?
    @State private var isLoading = false
    @State private var itemToReplace: ClothingItem?

    @FetchRequest(
        entity: ClothingItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ClothingItem.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<ClothingItem>

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                        ForEach(items) { item in
                            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100)
                                    .cornerRadius(8)
                                    .shadow(radius: 3)
                                    .contextMenu {
                                        Button {
                                            itemToReplace = item
                                            showingImagePicker = true
                                        } label: {
                                            Label("Replace Photo", systemImage: "photo")
                                        }
                                        
                                        Button(role: .destructive) {
                                            delete(item: item)
                                        } label: {
                                            Label("Delete Item", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Wardrobe")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            itemToReplace = nil // Ensure we're adding a new item
                            showingImagePicker = true
                        }) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingImagePicker, onDismiss: handleImagePickerDismiss) {
                    ImagePicker(image: $inputImage)
                }
                .sheet(isPresented: $showingCategorySheet) {
                    CategorySelectionView(image: $inputImage)
                }
                
                if isLoading {
                    Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                    ProgressView("Analyzing Image...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }

    private func handleImagePickerDismiss() {
        guard let newImage = inputImage else { return }
        
        if let item = itemToReplace {
            // This is a replacement
            replaceImage(for: item, with: newImage)
        } else {
            // This is a new item
            showingCategorySheet = true
        }
    }
    
    private func replaceImage(for item: ClothingItem, with newImage: UIImage) {
        isLoading = true
        APIManager.shared.fetchColors(for: newImage) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let colors):
                    item.imageData = newImage.jpegData(compressionQuality: 1.0)
                    item.primaryColorHex = colors.first ?? "#000000"
                case .failure(let error):
                    print("Error fetching colors for replacement: \(error.localizedDescription)")
                    item.imageData = newImage.jpegData(compressionQuality: 1.0)
                    item.primaryColorHex = "#000000" // Fallback color
                }
                
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
                isLoading = false
                itemToReplace = nil
            }
        }
    }

    private func delete(item: ClothingItem) {
        withAnimation {
            viewContext.delete(item)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct CategorySelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @Binding var image: UIImage?
    
    // Categories
    @State private var category: String = "Top"
    @State private var subCategory: String = "T-Shirt"
    @State private var occasion: String = "Casual"
    
    // Category Options
    let categories = ["Top", "Bottom", "Shoes", "Accessory"]
    let topSubCategories = ["T-Shirt", "Shirt", "Sweatshirt", "Jacket"]
    let bottomSubCategories = ["Jeans", "Pants", "Shorts", "Skirt"]
    let occasions = ["Casual", "Formal", "Party", "Workout"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Categorize Your Item")) {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(8)
                    }
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: category, perform: updateSubCategory)
                    
                    // Conditional Sub-Category Picker
                    if category == "Top" {
                        Picker("Type", selection: $subCategory) {
                            ForEach(topSubCategories, id: \.self) { Text($0) }
                        }
                    } else if category == "Bottom" {
                        Picker("Type", selection: $subCategory) {
                            ForEach(bottomSubCategories, id: \.self) { Text($0) }
                        }
                    }
                    
                    Picker("Occasion", selection: $occasion) {
                        ForEach(occasions, id: \.self) { Text($0) }
                    }
                }
                
                Button(action: analyzeAndSave) {
                    Text("Save Item")
                }
            }
            .navigationTitle("New Item")
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
            .onAppear(perform: setupInitialSubCategory)
        }
    }
    
    private func setupInitialSubCategory() {
        updateSubCategory(to: category)
    }
    
    private func updateSubCategory(to newCategory: String) {
        if newCategory == "Top" {
            subCategory = topSubCategories.first!
        } else if newCategory == "Bottom" {
            subCategory = bottomSubCategories.first!
        } else {
            subCategory = ""
        }
    }
    
    private func analyzeAndSave() {
        guard let image = image else { return }
        
        APIManager.shared.fetchColors(for: image) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let colors):
                    addItem(image: image, category: category, subCategory: subCategory, occasion: occasion, primaryColorHex: colors.first ?? "#000000")
                    dismiss()
                case .failure(let error):
                    print("Error fetching colors: \(error.localizedDescription)")
                    addItem(image: image, category: category, subCategory: subCategory, occasion: occasion, primaryColorHex: "#000000")
                    dismiss()
                }
            }
        }
    }

    private func addItem(image: UIImage, category: String, subCategory: String, occasion: String, primaryColorHex: String) {
        withAnimation {
            let newItem = ClothingItem(context: viewContext)
            newItem.id = UUID()
            newItem.timestamp = Date()
            newItem.imageData = image.jpegData(compressionQuality: 1.0)
            newItem.category = category
            newItem.subCategory = subCategory
            newItem.primaryColorHex = primaryColorHex
            newItem.occasion = occasion

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct SuggestionsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: ClothingItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ClothingItem.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<ClothingItem>
    
    @State private var selectedOccasion: String = "Casual"
    @State private var suggestedOutfit: Outfit?
    let occasions = ["Casual", "Formal", "Party", "Workout"]
    private let suggestionEngine = SuggestionEngine()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Picker("Occasion", selection: $selectedOccasion) {
                    ForEach(occasions, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                HStack(spacing: 20) {
                    Button(action: generateSuggestion) {
                        Label("Generate", systemImage: "sparkles")
                    }
                    .buttonStyle(.borderedProminent)

                    if suggestedOutfit != nil {
                        Button(action: clearOutfit) {
                            Label("Clear", systemImage: "xmark")
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
                
                if let outfit = suggestedOutfit {
                    OutfitView(outfit: outfit)
                } else {
                    Spacer()
                    Text("Tap 'Generate' to get an outfit suggestion.")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .navigationTitle("Suggestions")
        }
    }
    
    private func generateSuggestion() {
        withAnimation(.spring()) {
            suggestedOutfit = suggestionEngine.generateOutfit(from: Array(items), for: selectedOccasion)
        }
    }
    
    private func clearOutfit() {
        withAnimation(.spring()) {
            suggestedOutfit = nil
        }
    }
}

struct OutfitView: View {
    let outfit: Outfit

    var body: some View {
        VStack(spacing: 15) {
            if let topData = outfit.top.imageData, let topImage = UIImage(data: topData) {
                OutfitItemView(image: topImage, title: outfit.top.subCategory ?? "Top")
            }
            if let bottomData = outfit.bottom.imageData, let bottomImage = UIImage(data: bottomData) {
                OutfitItemView(image: bottomImage, title: outfit.bottom.subCategory ?? "Bottom")
            }
            if let shoes = outfit.shoes, let shoesData = shoes.imageData, let shoesImage = UIImage(data: shoesData) {
                OutfitItemView(image: shoesImage, title: "Shoes")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding()
        .transition(.opacity.combined(with: .scale))
    }
}

struct OutfitItemView: View {
    let image: UIImage
    let title: String
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(height: 140)
                .cornerRadius(10)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
