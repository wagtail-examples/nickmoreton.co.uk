class Copier {
    constructor() {
        this.copyBtns = document.querySelectorAll('[data-copy]');
    }
    init() {
        for (let i = 0; i < this.copyBtns.length; i++) {
            this.copyBtns[i].addEventListener('click', (e) => {
                e.preventDefault();
                this.copy(this.copyBtns[i]);
            });
        }
    }
    copy(btn) {
        text = btn.nextElementSibling.value;
        navigator.clipboard.writeText(text);
        copyMessageContainer = btn.parentElement.parentElement.querySelector('.copy');
        originalMessage = copyMessageContainer.innerHTML;
        copyMessageContainer.innerHTML = "Copied!";
        int = setInterval(() => {
            copyMessageContainer.innerHTML = originalMessage;
            clearInterval(int);
        }
        , 1000);
    }
}

module.exports = Copier;
