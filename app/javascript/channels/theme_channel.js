import consumer from "./consumer";

const onePagerId = document.body.dataset.onePagerId;;

consumer.subscriptions.create({ channel: "ThemeChannel", one_pager_id: onePagerId }, {
  connected() {
  },

  disconnected() {
  },

  received(data) {
    document.documentElement.setAttribute('data-theme', data.theme);
  }
});
