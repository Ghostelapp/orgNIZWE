import WidgetKit
import SwiftUI

@main
struct orgNIZWEWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TodayWidget()
        TopTasksWidget()
        HabitsWidget()
        NextEventWidget()
    }
}
