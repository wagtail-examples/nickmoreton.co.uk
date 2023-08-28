import "../styles/index.scss";
import Navigation from "./nav";
import TaglineAnimator from "./animate";
import AsidePositionSticky from "./aside";
// import Copier from "./copy";
import hljs from 'highlight.js';
import Copier from "./copier";

hljs.highlightAll();

const nav = new Navigation();
nav.init();

const tagline = new TaglineAnimator();
tagline.init();

const copy = new Copier();
copy.init();

const aside = new AsidePositionSticky();
aside.init();
