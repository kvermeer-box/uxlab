@import url(https://fonts.googleapis.com/css?family=Open+Sans:300,700,600,400);

/* Disable Salesforce Styling */

.noSidebarCell {
    padding: 0px !important;
}

.outerNoSidebar {
    padding: 0px !important;
}

.link, .link:hover {
    text-decoration: none;
}

/* Page CSS */

#main-container {
    width: 100%;
    height: 100%;
    min-height: 800px;
    background-image: -o-radial-gradient(50% 146%, #615275 0%, #D9D0D0 0%, #0081CA 100%);
    background-image: -moz-radial-gradient(50% 146%, #615275 0%, #D9D0D0 0%, #0081CA 100%);
    background-image: -ms-radial-gradient(50% 146%, #615275 0%, #D9D0D0 0%, #0081CA 100%);
    background-image: radial-gradient(50% 146%, #615275 0%, #D9D0D0 0%, #0081CA 100%);
    font-family: 'Open Sans', sans-serif;
}

/* Title */

#title-banner {
    padding-top: 20px;
}

#main-title {
    font-family: 'Open Sans', sans-serif;
    font-size: 72px;
    color: #FFFFFF;
    text-align: center;
    font-weight: 600;
}

#subtitle {
    margin-top: 20px;
    text-align: center;
    font-size: 17px;
    color: #FFFFFF;
    font-weight: 400;
}

#subtitle a {
    font-size: 17px;
    color: #FFFFFF;
    text-align: center;
    font-weight: 400;
}

/* Tiles */

#tile-container {
    margin: auto;
    text-align: center;
    margin-top: 40px;
}

@media (max-width:1200px) {
    #tile-container {
        width: 900px;
    }
}

@media (min-width: 1400px) {
    #tile-container {
        width: 1350px;
    }
    /* was 1375 */
}

@media (min-width: 1201px) and (max-width: 1399px) {
    #tile-container {
        width: 1120px;
    }
    /* was 1100 */
}

#tile-centerer {
    text-align:left;
    display: inline-block;
}

.tile {
    display: inline-block;
    width: 220px;
    height: 132px;
    border-radius: 2px;
    background: #FFFFFF;
    -moz-box-shadow:    0px 3px 3px 0px rgba(0,0,0,0.20);
    box-shadow:         0px 3px 3px 0px rgba(0,0,0,0.20);
    margin-bottom: 3px;
    margin-right: 1px;
    position: relative;
    vertical-align: top;
}

.tile:hover {
    background-image: -o-radial-gradient(50% 100%, #FFFFFF 0%, #EFEFEF 100%);
    background-image: -moz-radial-gradient(50% 100%, #FFFFFF 0%, #EFEFEF 100%);
    background-image: -ms-radial-gradient(50% 100%, #FFFFFF 0%, #EFEFEF 100%);
    background-image: radial-gradient(50% 100%, #FFFFFF 0%, #EFEFEF 100%);
    cursor: pointer;
}

.tile-title {
    font-family: 'Open Sans', sans-serif;
    font-size: 18px;
    color: #008CBA;
    font-weight: 400;
    height: 60px;
    display: table;
    width: 100%;
}

.tile-title p {
    display: table-cell; 
    vertical-align: middle; 
    text-align: center; 
}

/* Tile (i) info button */

.info-box {
    text-align: right;
    width:100%;
    height:30px;
}

.info-sign {
    width: 16px;
    height: 16px;
    font-size: 10px;
    color: #CBCBCB;
    border: 1px solid #CBCBCB;
    border-radius: 20px;
    display: inline-block;
    text-align: center;
    margin-right: 5px;
    margin-top: 5px;
    position: relative;
    z-index: 1000;
}

.info-sign:hover {

}

.info-letter {
    font-size: 10px;
    display: block;
    text-align: center;
    width: 100%;
    height: 16px;
    line-height: 16px;
}

/* Info display upon hovering over info button */

.info-text-box {
    position: absolute;
    top: 0px;
    left: 0px;
    background: rgb(5,94,144);
    width: 100%;
    height: 100%;
    display: none;
}

.info-text {
    font-size: 13px;
    color: #FFFFFF;
    padding: 15px;
    display: inline-block;
    font-weight: 300;
}

/* Back button */

.back-button-text {
    color: #FFFFFF;
    font-size: 18px;
    display: inline-block;
    height: 40px;
    line-height: 40px;
    vertical-align: top;
    margin-left: 10px;
}

.back-button-image {
    display: inline-block;
}

.back-button-container {
    margin-left: 30px;
}