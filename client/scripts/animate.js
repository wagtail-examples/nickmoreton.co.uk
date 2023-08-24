class TaglineAnimator {
    constructor() {
        this.animated = document.querySelector('[data-animated]');
        this.swaps = ["using", "liking", "loving"]
    }
    init() {
        if (this.animated) {
            this.animate();
            this.animated.innerHTML = this.swaps[0];
        }
    }
    animate() {
        let i = 0;
        int = setInterval(() => {
            this.animated.innerHTML = this.swaps[i];
            i++;
            if (i === this.swaps.length) {
                // i = 0;
                clearInterval(int);
                this.animated.classList.add('finished');
            }
        }, 1000);
    }
}

module.exports = TaglineAnimator;
