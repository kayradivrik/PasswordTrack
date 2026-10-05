const api = (typeof browser !== "undefined") ? browser : chrome;
const BASE = "http://127.0.0.1:38917";

const statusEl = document.getElementById("status");
const listEl = document.getElementById("list");
const setupEl = document.getElementById("setup");

// Sayfadaki kullanıcı adı/parola alanlarını doldurur (sayfa bağlamında çalışır)
function fillCredentials(username, password) {
  const setVal = (el, v) => {
    const proto = Object.getPrototypeOf(el);
    Object.getOwnPropertyDescriptor(proto, "value").set.call(el, v);
    el.dispatchEvent(new Event("input", { bubbles: true }));
    el.dispatchEvent(new Event("change", { bubbles: true }));
  };
  const pwd = document.querySelector('input[type="password"]');
  if (!pwd) return false;
  const inputs = Array.from(document.querySelectorAll('input[type="text"], input[type="email"], input:not([type])'));
  const user = inputs.filter(i => i.compareDocumentPosition(pwd) & Node.DOCUMENT_POSITION_FOLLOWING).pop();
  if (user) setVal(user, username);
  setVal(pwd, password);
  return true;
}

async function main() {
  const store = await api.storage.local.get("token");
  const token = store.token;
  if (!token) { setupEl.style.display = "block"; statusEl.textContent = "Token gerekli."; return; }

  const [tab] = await api.tabs.query({ active: true, currentWindow: true });
  let host = "";
  try { host = new URL(tab.url).hostname; } catch (e) {}

  let res;
  try {
    res = await fetch(`${BASE}/logins?host=${encodeURIComponent(host)}`, { headers: { "X-VoidPass-Token": token } });
  } catch (e) {
    statusEl.textContent = "VoidPass uygulaması çalışmıyor.";
    return;
  }
  if (res.status === 423) { statusEl.textContent = "Kasa kilitli. Önce VoidPass'i açın."; return; }
  if (res.status === 403) { statusEl.textContent = "Geçersiz token."; setupEl.style.display = "block"; return; }

  const logins = await res.json();
  if (!logins.length) { statusEl.textContent = `${host} için kayıt bulunamadı.`; return; }
  statusEl.textContent = `${logins.length} hesap bulundu — doldurmak için tıklayın:`;

  logins.forEach(l => {
    const div = document.createElement("div");
    div.className = "item";
    div.innerHTML = `<b></b><span class="muted"></span>`;
    div.querySelector("b").textContent = l.service;
    div.querySelector("span").textContent = l.username;
    div.onclick = async () => {
      await api.scripting.executeScript({
        target: { tabId: tab.id },
        func: fillCredentials,
        args: [l.username, l.password]
      });
      window.close();
    };
    listEl.appendChild(div);
  });
}

document.getElementById("save").onclick = async () => {
  await api.storage.local.set({ token: document.getElementById("token").value.trim() });
  setupEl.style.display = "none";
  main();
};

main();
