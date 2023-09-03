import "../styles/index.scss";
import Navigation from "./nav";
import TaglineAnimator from "./animate";
import AsidePositionSticky from "./aside";
import Copier from "./copier";

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

const nav = new Navigation();
nav.init();

const tagline = new TaglineAnimator();
tagline.init();

const copy = new Copier();
copy.init();

const aside = new AsidePositionSticky();
aside.init();
