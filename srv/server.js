const cds = require('@sap/cds');

const NOTIFICATIONS = [
  {
    NotificationId: "notif-dcep-001",
    IsRead: false,
    Priority: "HIGH",
    Text: "Notification Test 1: Direct Object Page",
    SubTitle: "Click to open the DCEP Project object page directly",
    CreatedAt: "/Date(1756814400000)/",
    NavigationTargetObject: "ProjectList",
    NavigationTargetAction: "display",
    NavigationTargetParams: [
      { Key: "ID", Value: "b2c3d4e5-0000-0000-0000-000000000001" }
    ]
  },
  {
    NotificationId: "notif-dcep-002",
    IsRead: false,
    Priority: "MEDIUM",
    Text: "Notification Test 2: Single Filter — List filtered by Type = AI Build",
    SubTitle: "Click to open Project List pre-filtered by type",
    CreatedAt: "/Date(1756800000000)/",
    NavigationTargetObject: "ProjectList",
    NavigationTargetAction: "display",
    NavigationTargetParams: [
      { Key: "type", Value: "AI Build" }
    ]
  },
  {
    NotificationId: "notif-dcep-003",
    IsRead: false,
    Priority: "MEDIUM",
    Text: "Notification Test 3: Multi-Value Same Field — Name IN (Azure AI Insights Platform, Smart Meter Analytics)",
    SubTitle: "Uses sap-xapp-state to filter by 2 specific project names",
    CreatedAt: "/Date(1756790000000)/",
    NavigationTargetObject: "ProjectList",
    NavigationTargetAction: "display",
    NavigationTargetParams: []
  }
];

cds.on('bootstrap', app => {
  // FLP polls this every 10s for the bell count
  app.get(/^\/api\/notifications\/GetBadgeNumber\(\)$/, (_req, res) => {
    const count = NOTIFICATIONS.filter(n => !n.IsRead).length;
    res.json({ value: count });
  });

  app.get('/api/notifications/Notifications', (_req, res) => {
    res.json({ '@odata.context': '$metadata#Notifications', value: NOTIFICATIONS });
  });

  app.patch(/^\/api\/notifications\/Notifications\(/, (req, res) => {
    const match = req.path.match(/Notifications\('([^']+)'\)/);
    if (match) {
      const notif = NOTIFICATIONS.find(n => n.NotificationId === match[1]);
      if (notif) notif.IsRead = true;
    }
    res.status(204).end();
  });

  // notif-dcep-003 uses sap-xapp-state for multi-value filter — browser creates
  // the AppState on load and posts the key here so we can put it in the params
  app.post('/api/notifications/appstate', (req, res) => {
    let body = '';
    req.on('data', c => body += c);
    req.on('end', () => {
      const { notifId, key } = JSON.parse(body);
      const notif = NOTIFICATIONS.find(n => n.NotificationId === notifId);
      if (notif) notif.NavigationTargetParams = [{ Key: "sap-xapp-state", Value: key }];
      res.status(204).end();
    });
  });
});