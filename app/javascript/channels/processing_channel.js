import consumer from "./consumer"

consumer.subscriptions.create(
  { channel: "ProcessingChannel" },
  {
    received(data) {
      console.log("Dados recebidos:", data);
      const progressContainer = document.getElementById("progress-container");
      if (progressContainer) {
        Turbo.renderStreamMessage(data);
      }
    }
  }
);