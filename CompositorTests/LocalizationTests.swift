import AppKit
import Testing
@testable import Compositor

@MainActor
struct LocalizationTests {
    private func bundle(_ language: String) throws -> Bundle {
        let path = try #require(Bundle.main.path(forResource: language, ofType: "lproj"))
        return try #require(Bundle(path: path))
    }

    @Test func compiledResourcesIncludeEnglishAndSimplifiedChinese() throws {
        let english = try bundle("en")
        let chinese = try bundle("zh-Hans")
        #expect(L10n.string("New canvas", bundle: english) == "New canvas")
        #expect(L10n.string("New canvas", bundle: chinese) == "新建画布")
        #expect(L10n.string("Multiply", bundle: chinese) == "正片叠底")
        #expect(L10n.string("Camera Raw Filter", bundle: chinese) == "Camera Raw 滤镜")
        #expect(L10n.string("A missing translation", bundle: chinese) == "A missing translation")
    }

    @Test func chineseBlendModeTitlesStillPreviewCommitAndUndo() throws {
        let session = EditorSession()
        session.createDocument(width: 4, height: 4, emptyLayer: true)
        session.history.markSaved()
        let undoCount = session.history.undoCount
        let coordinator = BlendModePicker.Coordinator(session: session)
        let button = NSPopUpButton()
        let chinese = try bundle("zh-Hans")
        for mode in LayerBlendMode.allCases {
            button.addItem(withTitle: L10n.string(mode.rawValue, bundle: chinese))
            let item = try #require(button.lastItem)
            item.representedObject = mode.rawValue
            #expect(BlendModePicker.mode(for: item) == mode)
        }
        let menu = try #require(button.menu)
        let multiply = try #require(button.itemArray.first { BlendModePicker.mode(for: $0) == .multiply })
        coordinator.menuWillOpen(menu)
        coordinator.menu(menu, willHighlight: multiply)
        #expect(session.activeLayer?.blendMode == .normal)
        #expect(session.displayedBlendMode(for: try #require(session.activeLayer)) == .multiply)
        button.select(multiply)
        coordinator.choose(button)
        #expect(session.activeLayer?.blendMode == .multiply)
        #expect(session.history.undoCount == undoCount + 1)
        session.undo()
        #expect(session.activeLayer?.blendMode == .normal)
        #expect(!session.isModified)
    }

    @Test func localizationPreservesProjectValuesAndShortcutIDs() throws {
        #expect(try JSONDecoder().decode(String.self, from: JSONEncoder().encode(LayerBlendMode.multiply)) == "Multiply")
        #expect(try JSONDecoder().decode(String.self, from: JSONEncoder().encode(AdjustmentKind.hsv)) == "Hue/Saturation")
        let undo = try #require(ShortcutDefinition.all.first { $0.title == "Undo" })
        #expect(undo.id == "Menus:Undo")
        let saved = ["Menus:Undo": ShortcutChord("u", 1)]
        let decoded = try JSONDecoder().decode([String: ShortcutChord].self, from: JSONEncoder().encode(saved))
        #expect(decoded[undo.id] == ShortcutChord("u", 1))
    }

    @Test func chineseCommandSearchRunsTheSelectedAction() {
        var ran = false
        let entry = CommandPaletteEntry(id: "stable.blur", title: "滤镜 › 高斯模糊…", shortcut: nil,
                                        isEnabled: true, perform: { ran = true })
        let result = CommandPaletteSearch.rank([entry], query: "高斯")
        #expect(result.first?.id == "stable.blur")
        result.first?.perform()
        #expect(ran)
    }

    @Test func realMenuLocalizesDynamicFilterNamesAndOmitsSearchItself() throws {
        let menu = try #require(NSApp.mainMenu)
        let entries = CommandPaletteMenu.entries(in: menu, skipping: CommandPaletteController.skipped)
        let title = "\(L10n.string("Filter")) › \(L10n.string("Gaussian Blur"))…"
        #expect(entries.contains { $0.title == title })
        #expect(!entries.contains { $0.title.hasSuffix(L10n.string("Search Commands…")) })
    }
}
