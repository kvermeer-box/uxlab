/**** PAGE FLIP STUFF ****/

.crocodoc-pageflip .crocodoc-page-visible,
.crocodoc-pageflip .crocodoc-page-next,
.crocodoc-pageflip .crocodoc-page-prev {
    visibility: visible !important;
}

.crocodoc-pageflip .crocodoc-page-before,
.crocodoc-pageflip .crocodoc-page-after {
    visibility: visible;
}

/* Visible pages should always be on top */
.crocodoc-pageflip .crocodoc-page-visible {
    z-index: 2;
}

/* Next/Previous page should sit above other pages so it doesn't look weird when
transitioning */
.crocodoc-pageflip .crocodoc-page-prev,
.crocodoc-pageflip .crocodoc-page-next {
    z-index: 1;
}

.crocodoc-pageflip .crocodoc-doc {
    overflow: visible;
    -webkit-perspective: 2000px;
    perspective: 2000px;
    -webkit-transform-style: preserve-3d;
    transform-style: preserve-3d;
    -webkit-transform-origin: 50% 50%;
    transform-origin: 50% 50%;
}

.crocodoc-pageflip .crocodoc-page {
    -webkit-backface-visibility: hidden;
    -moz-backface-visibility: hidden;
    backface-visibility: hidden;
    -webkit-transform-style: preserve-3d;
    transform-style: preserve-3d;
    -webkit-transition: -webkit-transform 0.8s, z-index 0s linear 0.1s;
    transition: transform 0.8s, z-index 0s linear 0.1s;
}

.crocodoc-pageflip .crocodoc-page:nth-child(odd) {
    -webkit-transform-origin: right top;
    transform-origin: right top;
}
.crocodoc-pageflip .crocodoc-page:nth-child(even) {
    -webkit-transform-origin: left top;
    transform-origin: left top;
}

.crocodoc-pageflip .crocodoc-page-visible:nth-child(odd) {
    -webkit-transform: rotateY(0.1deg);
    transform: rotateY(0.1deg);
}
.crocodoc-pageflip .crocodoc-page-visible:nth-child(even) {
    -webkit-transform: rotateY(-0.1deg);
    transform: rotateY(-0.1deg);
}

.crocodoc-pageflip .crocodoc-page-before-buffer,
.crocodoc-pageflip .crocodoc-page-after-buffer {
    -webkit-transition-delay: 0s, 0.4s;
    transition-delay: 0s, 0.4s;
    visibility: visible !important;
}

.crocodoc-pageflip .crocodoc-page-before,
.crocodoc-pageflip .crocodoc-page-after {
    visibility: hidden;
}

.crocodoc-pageflip .crocodoc-page-before:nth-child(odd) {
    -webkit-transform: none;
    transform: none;
}
.crocodoc-pageflip .crocodoc-page-before:nth-child(even) {
    -webkit-transform: rotateY(-180deg);
    transform: rotateY(-180deg);
}

.crocodoc-pageflip .crocodoc-page-after:nth-child(odd) {
    -webkit-transform: rotateY(180deg);
    transform: rotateY(180deg);
}
.crocodoc-pageflip .crocodoc-page-after:nth-child(even) {
    -webkit-transform: none;
    transform: none;
}

/* Create a gradient to make it look more like a book */
.crocodoc-pageflip .crocodoc-page:nth-child(odd) .crocodoc-page-overlay {
    background-image: linear-gradient(to right, rgba(136,136,136,0) 0%,rgba(136,136,136,0) 65%,rgba(136,136,136,0.03) 88%,rgba(136,136,136,0.01) 94%,rgba(136,136,136,0.03) 95%,rgba(136,136,136,0.1) 100%);
}
.crocodoc-pageflip .crocodoc-page:nth-child(even) .crocodoc-page-overlay {
    background-image: linear-gradient(to right, rgba(0,0,0,0.08) 0%,rgba(0,0,0,0.05) 1%,rgba(0,0,0,0.01) 15%,rgba(0,0,0,0) 25%,rgba(0,0,0,0) 100%);
}