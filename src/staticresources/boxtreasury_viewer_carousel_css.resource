

.crocodoc-carousel .crocodoc-doc {
    background: transparent;
    overflow: visible;
    -webkit-perspective: 500px;
    perspective: 500px;
    -webkit-perspective-origin: 50% 50%;
    perspective-origin: 50% 50%;
    -webkit-transform-style: preserve-3d;
    transform-style: preserve-3d;
}

.crocodoc-carousel .crocodoc-page-inner {
    border: 0;
}

.crocodoc-carousel .crocodoc-page {
    -webkit-transform-style: preserve-3d;
    transform-style: preserve-3d;
    -webkit-transition: -webkit-transform 0.5s, opacity 0.3s;
    transition: transform 0.5s, opacity 0.3s;
}

.crocodoc-carousel .crocodoc-page-prev,
.crocodoc-carousel .crocodoc-page-next,
.crocodoc-carousel .crocodoc-page-before,
.crocodoc-carousel .crocodoc-page-after {
    visibility: visible !important;
}
.crocodoc-carousel .crocodoc-current-page {
    -webkit-transform: none;
    transform: none;
}
.crocodoc-carousel .crocodoc-page-before {
    -webkit-transform: rotateY(-90deg) translateX(-200%);
    transform: rotateY(-90deg) translateX(-200%);
    opacity: 0;
}
.crocodoc-carousel .crocodoc-page-after {
    -webkit-transform: rotateY(90deg) translateX(200%);
    transform: rotateY(90deg) translateX(200%);
    opacity: 0;
}
.crocodoc-carousel .crocodoc-page-prev {
    -webkit-transform: rotateY(-30deg) translateX(-100%);
    transform: rotateY(-30deg) translateX(-100%);
    z-index: 1;
    opacity: 1;
}
.crocodoc-carousel .crocodoc-page-next {
    -webkit-transform: rotateY(30deg) translateX(100%);
    transform: rotateY(30deg) translateX(100%);
    z-index: 1;
    opacity: 1;
}