import BandwidthGuardCore
import SwiftUI

struct NetworksView: View {
    @EnvironmentObject private var store: AppStore
    @State private var editingProfile: NetworkProfile?
    @State private var isAddingProfile = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionHeader(title: "Profiles", trailing: nil)
                Spacer()
                Button {
                    isAddingProfile = true
                } label: {
                    Image(systemName: "plus")
                }
                .controlSize(.small)
                .help("Add profile")
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)

            VStack(spacing: 8) {
                ForEach(store.profiles) { profile in
                    NetworkProfileRow(
                        profile: profile,
                        selected: profile.id == store.selectedProfileID,
                        canDelete: store.profiles.count > 1,
                        onSelect: {
                            store.selectProfile(profile)
                        },
                        onEdit: {
                            editingProfile = profile
                        },
                        onReset: {
                            store.resetRules(for: profile)
                        },
                        onDelete: {
                            store.deleteProfile(profile)
                        }
                    )
                }
            }
            .padding(.horizontal, 14)

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Default rule")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Apps without a custom rule follow this setting.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { store.selectedProfile.defaultAllowed },
                        set: { store.setDefaultAllowed($0) }
                    ))
                    .labelsHidden()
                    .help("Default allow or block for this profile")
                }

                HStack {
                    Label(store.selectedProfile.isMetered ? "Metered profile" : "Unmetered profile", systemImage: store.selectedProfile.isMetered ? "cellularbars" : "wifi")
                    Spacer()
                    Text("\(store.selectedProfile.appRules.count) custom rules")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(nsColor: .controlBackgroundColor)))
            .padding(.horizontal, 14)

            Spacer()
        }
        .sheet(isPresented: $isAddingProfile) {
            ProfileEditorSheet(
                title: "New Profile",
                name: "",
                networkHint: "",
                isMetered: true,
                defaultAllowed: false,
                onCancel: {
                    isAddingProfile = false
                },
                onSave: { name, networkHint, isMetered, defaultAllowed in
                    store.addProfile(
                        name: name,
                        networkHint: networkHint,
                        isMetered: isMetered,
                        defaultAllowed: defaultAllowed
                    )
                    isAddingProfile = false
                }
            )
        }
        .sheet(item: $editingProfile) { profile in
            ProfileEditorSheet(
                title: "Edit Profile",
                name: profile.name,
                networkHint: profile.networkHint,
                isMetered: profile.isMetered,
                defaultAllowed: profile.defaultAllowed,
                onCancel: {
                    editingProfile = nil
                },
                onSave: { name, networkHint, isMetered, defaultAllowed in
                    store.updateProfile(
                        profile,
                        name: name,
                        networkHint: networkHint,
                        isMetered: isMetered,
                        defaultAllowed: defaultAllowed
                    )
                    editingProfile = nil
                }
            )
        }
    }
}

struct NetworkProfileRow: View {
    var profile: NetworkProfile
    var selected: Bool
    var canDelete: Bool
    var onSelect: () -> Void
    var onEdit: () -> Void
    var onReset: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onSelect) {
                profileContent
            }
            .buttonStyle(.plain)

            Menu {
                Button("Edit", systemImage: "pencil", action: onEdit)
                Button("Reset Rules", systemImage: "arrow.counterclockwise", action: onReset)
                Divider()
                Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
                    .disabled(!canDelete)
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .menuStyle(.button)
            .buttonStyle(.plain)
            .frame(width: 26, height: 26)
            .help("Profile actions")
        }
    }

    private var profileContent: some View {
        HStack(spacing: 10) {
            Image(systemName: profile.isMetered ? "iphone.gen3.radiowaves.left.and.right" : "wifi")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(selected ? Color.accentColor : Color.secondary)
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 2) {
                Text(profile.name)
                    .font(.system(size: 13, weight: .semibold))
                Text(profile.networkHint)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(selected ? Color.accentColor : Color.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(nsColor: selected ? .selectedContentBackgroundColor : .controlBackgroundColor).opacity(selected ? 0.22 : 1)))
    }
}

struct ProfileEditorSheet: View {
    var title: String
    var onCancel: () -> Void
    var onSave: (String, String, Bool, Bool) -> Void

    @State private var name: String
    @State private var networkHint: String
    @State private var isMetered: Bool
    @State private var defaultAllowed: Bool

    init(
        title: String,
        name: String,
        networkHint: String,
        isMetered: Bool,
        defaultAllowed: Bool,
        onCancel: @escaping () -> Void,
        onSave: @escaping (String, String, Bool, Bool) -> Void
    ) {
        self.title = title
        self.onCancel = onCancel
        self.onSave = onSave
        _name = State(initialValue: name)
        _networkHint = State(initialValue: networkHint)
        _isMetered = State(initialValue: isMetered)
        _defaultAllowed = State(initialValue: defaultAllowed)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3.weight(.semibold))

            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
                GridRow {
                    Text("Name")
                        .foregroundStyle(.secondary)
                    TextField("Phone Hotspot", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 260)
                }

                GridRow {
                    Text("Network")
                        .foregroundStyle(.secondary)
                    TextField("metered, trusted, office", text: $networkHint)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 260)
                }
            }
            .font(.system(size: 13))

            Toggle("Metered connection", isOn: $isMetered)
            Toggle("Allow apps by default", isOn: $defaultAllowed)

            HStack {
                Spacer()
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)
                Button("Save") {
                    onSave(name, networkHint, isMetered, defaultAllowed)
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 420)
    }
}
