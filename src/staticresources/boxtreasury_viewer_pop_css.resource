/***** "PRESENTATION MODE" PAGE TRANSITIONS *****/

.crocodoc-presentation .crocodoc-page {
    -webkit-transition: visibility 0s, opacity 0.3s, -webkit-transform 0.25s;
    transition: visibility 0s, opacity 0.3s, transform 0.25s;
}
.crocodoc-presentation .crocodoc-page-next {
    visibility: visible !important;
}
.crocodoc-presentation .crocodoc-current-page {
    -webkit-transform: none;
    transform: none;
    opacity: 1;
}
.crocodoc-presentation .crocodoc-page-before,
.crocodoc-presentation .crocodoc-page-before-buffer {
    -webkit-transform: rotate(-3deg) translate(-12%, -12%);
    transform: rotate(-3deg) translate(-12%, -12%);
    -webkit-transition-delay: 0.3s, 0s, 0s;
    transition-delay: 0.3s, 0s, 0s;
    opacity: 0;
}
.crocodoc-presentation .crocodoc-page-after,
.crocodoc-presentation .crocodoc-page-after-buffer {
    -webkit-transition-delay: 0s;
    transition-delay: 0s;
    visibility: hidden;
    opacity: 0;
}