class AsidePositionSticky {
    constructor() {
        this.aside = document.querySelector('aside');
        this.nav = document.querySelector('nav');
        this.header = document.querySelector('header');
        this.asideContainer = this.aside.parentNode;
        this.maxOffset = document.body.scrollHeight;
    }
    init() {
        if (this.aside) {
            this.checkPosition();
        }
    }
    checkPosition() {
        document.onscroll = () => {
            this.navHeight = this.nav.offsetHeight;
            this.headerHeight = this.header.offsetHeight;
            this.totalHeight = this.navHeight + this.headerHeight;
            this.offsetTop = document.scrollingElement.scrollTop;
            this.asideTop = this.offsetTop - this.totalHeight;
            this.screenWidth = window.innerWidth;
            if (this.screenWidth >= 800) {

                if (this.totalHeight < window.scrollY) {
                    this.aside.style.transform = `translateY(${this.asideTop}px)`;
                    this.aside.classList.add('sticky');
                } else {
                    this.aside.style.transform = `translateY(0px)`;
                    this.aside.classList.remove('sticky');
                }
            } else {
                this.aside.style.transform = `translateY(0px)`;
                this.aside.classList.remove('sticky');
            }

        }

    }
}

module.exports = AsidePositionSticky;
