// Highlight.js
import hljs from 'highlight.js/lib/core';
import bash from 'highlight.js/lib/languages/bash';
import css from 'highlight.js/lib/languages/css';
import javascript from 'highlight.js/lib/languages/javascript';
import json from 'highlight.js/lib/languages/json';
import python from 'highlight.js/lib/languages/python';
import xml from 'highlight.js/lib/languages/xml';
import yaml from 'highlight.js/lib/languages/yaml';

hljs.registerLanguage('bash', bash);
hljs.registerLanguage('css', css);
hljs.registerLanguage('javascript', javascript);
hljs.registerLanguage('json', json);
hljs.registerLanguage('python', python);
hljs.registerLanguage('xml', xml);
hljs.registerLanguage('yaml', yaml);
hljs.highlightAll();

const animatedTagline = document.querySelector('[data-animated]');
const animatedItems = ["using", "liking", "loving"];
if (animatedTagline) {
    animate(animatedTagline, animatedItems);
}

function animate(tagLine, items) {
    let count = 0;
    let interval = setInterval(() => {
        count++;
        if (count === items.length - 1) {
            tagLine.classList.add('finished');
            clearInterval(interval);
        }
        tagLine.innerHTML = items[count];
    }, 2000);
}

// const copy = new Copier();
// copy.init();

const aside = document.querySelector('aside');
if (aside) {
    document.onscroll = () => {
        checkPosition();
    }
}

function checkPosition() {
    const nav = document.querySelector('nav');
    const header = document.querySelector('header');
    const asideTop = document.scrollingElement.scrollTop - (nav.offsetHeight + header.offsetHeight);
    const screenWidth = window.innerWidth;
    if (screenWidth >= 1280) {
        if (nav.offsetHeight + header.offsetHeight < window.scrollY) {
            aside.style.transform = `translateY(${asideTop}px)`;
            aside.classList.add('sticky');
        } else {
            aside.style.transform = `translateY(0px)`;
            aside.classList.remove('sticky');
        }
    } else {
        aside.style.transform = `translateY(0px)`;
        aside.classList.remove('sticky');
    }
}

const copyButtons = document.querySelectorAll('[data-copy]');
if (copyButtons) {
    copyButtons.forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            const text = btn.parentElement.nextElementSibling.value;
            navigator.clipboard.writeText(text);
            const copyMessageContainer = btn.parentElement.parentElement.querySelector('.copy');
            const originalMessage = copyMessageContainer.innerHTML;
            copyMessageContainer.innerHTML = "Copied!";
            const int = setInterval(() => {
                copyMessageContainer.innerHTML = originalMessage;
                clearInterval(int);
            }, 1000);
        });
    });
}

const navIcon = document.querySelector('.menu-switch');
const nav = document.querySelector('nav');
const state = {
    open: false
}

if (navIcon) {
    navIcon.addEventListener('click', () => {
        toggleNav();
    });
}

function toggleNav() {
    if (state.open) {
        nav.dataset.state = '';
        state.open = false;
    } else {
        nav.dataset.state = 'mobile-active';
        state.open = true;
    }
}
