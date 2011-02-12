RailsDevDirectory::Application.config.middleware.use ExceptionNotifier, 
  :sender_address => %{"notifier" <notifier@example.com>},
  :exception_recipients => %w{exceptions@example.com}
