import "../styles/index.scss";
import Navigation from "./nav";
import TaglineAnimator from "./animate";

const nav = new Navigation();
nav.init();

const tagline = new TaglineAnimator();
tagline.init();
