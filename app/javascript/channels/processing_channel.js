consumer.subscriptions.create(
  { channel: "ProcessingChannel" },
  {
    received(data) {
      const progressContainer = document.getElementById("progress-container");
      if (progressContainer) {
        Turbo.renderStreamMessage(data);
      }
    }
  }
);