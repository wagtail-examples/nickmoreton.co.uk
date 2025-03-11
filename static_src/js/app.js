/**
 * This is a simple example of a class in ES6.
 * It will log a message to the console.
 * Remove this content and write your scripts as required.
 */
class ShowMessage {
    constructor(times=3) {
        this.message = 'Hello from Wagtail starter kit!';
        this.times = times;
    }

    showMessage() {
        for (let i = 0; i < this.times; i++) {
            console.log(this.message);
        }
    }
}

const showMessage = new ShowMessage();
showMessage.showMessage();
