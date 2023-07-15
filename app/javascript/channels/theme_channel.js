import consumer from "./consumer";

const onePagerId = document.body.dataset.onePagerId;;

consumer.subscriptions.create({ channel: "ThemeChannel", one_pager_id: onePagerId }, {
  connected() {
    console.log(onePagerId);
    console.log("Connected to ThemeChannel");
  },

  disconnected() {
    console.log("Disconnected from ThemeChannel");
  },

  received(data) {
    console.log("Received theme change:", data);
    document.documentElement.setAttribute('data-theme', data.theme);
  }
});
