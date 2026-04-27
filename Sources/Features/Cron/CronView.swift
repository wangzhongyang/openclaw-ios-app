import SwiftUI

struct CronView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        List {
            if let cronStatus = appState.cronStatus {
                Section("Status") {
                    DetailRow(label: "Enabled", value: cronStatus.enabled ? "Yes" : "No")
                    DetailRow(label: "Jobs", value: "\(cronStatus.jobs)")
                    if let nextWake = cronStatus.nextWakeAtMs {
                        DetailRow(label: "Next Wake", value: formatTimestamp(nextWake))
                    }
                }
            }

            if !appState.cronJobs.isEmpty {
                Section("Jobs") {
                    ForEach(appState.cronJobs) { job in
                        NavigationLink(destination: CronJobDetailView(job: job)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(job.name)
                                    .font(.headline)
                                Text(scheduleDescription(job.schedule))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                HStack(spacing: 8) {
                                    StatusIndicator(text: "Enabled", active: job.enabled)
                                }
                            }
                        }
                    }
                }
            }

            if let cronStatus = appState.cronStatus, appState.cronJobs.isEmpty {
                ProgressView("Loading cron jobs...")
            }
        }
        .navigationTitle("Cron")
    }

    private func scheduleDescription(_ schedule: CronSchedule) -> String {
        switch schedule {
        case .at(let at): return "At: \(at)"
        case .every(let everyMs, _): return "Every \(everyMs / 1000)s"
        case .cron(let expr, _, _): return expr
        }
    }

    private func formatTimestamp(_ ms: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: ms / 1000)
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct CronJobDetailView: View {
    let job: CronJob

    var body: some View {
        Form {
            Section("Info") {
                DetailRow(label: "Name", value: job.name)
                DetailRow(label: "ID", value: job.id)
                DetailRow(label: "Target", value: job.sessionTarget)
            }

            Section("Status") {
                StatusIndicator(text: "Enabled", active: job.enabled)
                if let running = job.state?.runningAtMs {
                    StatusIndicator(text: "Running", active: true)
                }
            }

            if let state = job.state {
                Section("State") {
                    if let lastRun = state.lastRunAtMs {
                        DetailRow(label: "Last Run", value: formatTimestamp(lastRun))
                    }
                    if let lastStatus = state.lastRunStatus {
                        DetailRow(label: "Last Status", value: lastStatus)
                    }
                    if let nextRun = state.nextRunAtMs {
                        DetailRow(label: "Next Run", value: formatTimestamp(nextRun))
                    }
                    if let errors = state.consecutiveErrors, errors > 0 {
                        DetailRow(label: "Consecutive Errors", value: "\(errors)")
                    }
                }
            }

            if let delivery = job.delivery {
                Section("Delivery") {
                    DetailRow(label: "Mode", value: delivery.mode)
                    if let channel = delivery.channel {
                        DetailRow(label: "Channel", value: channel)
                    }
                }
            }
        }
        .navigationTitle(job.name)
    }

    private func formatTimestamp(_ ms: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: ms / 1000)
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
