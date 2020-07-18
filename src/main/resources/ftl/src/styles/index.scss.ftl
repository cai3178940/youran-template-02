@import './variables.scss';
@import './mixin.scss';
@import './transition.scss';
@import './element-ui.scss';
@import './sidebar.scss';

body {
  height: 100%;
  -moz-osx-font-smoothing: grayscale;
  -webkit-font-smoothing: antialiased;
  text-rendering: optimizeLegibility;
  font-family: Helvetica Neue, Helvetica, PingFang SC, Hiragino Sans GB, Microsoft YaHei, Arial, sans-serif;
}

label {
  font-weight: 700;
}

html {
  height: 100%;
  box-sizing: border-box;
}

#app {
  height: 100%;
}

*,
*:before,
*:after {
  box-sizing: inherit;
}

a:focus,
a:active {
  outline: none;
}

a,
a:focus,
a:hover {
  cursor: pointer;
  color: inherit;
  text-decoration: none;
}

div:focus {
  outline: none;
}

.clearfix {
  &:after {
    visibility: hidden;
    display: block;
    font-size: 0;
    content: " ";
    clear: both;
    height: 0;
  }
}

// main-container global css
.app-container {
  padding: 20px;
}

.form-item-show {
  font-size: 14px;
  color: #8c8f95;
}

.filter-container {
  padding-bottom: 10px;

  .filter-item {
    vertical-align: middle;
    margin-bottom: 10px;
  }
}

.table-inner-mtm {
  font-size: 11px;
  color: #FFFFFF;
  padding: 2px;
  border: 2px solid transparent;
  border-radius:4px;
  margin: 2px;
  user-select: none;
  background-color: #FFA500;
}

.table-inner-button {
  margin-top: 2px;
  margin-bottom: 2px;
}

.vue-grid-item {
  .el-card__header {
    height: 30px;
    line-height:30px;
    padding: 0px 10px;
  }
  .el-card__body {
    padding: 0px;
  }
  .card-hidden {
    border-style: none;
    .el-card__header {
      border-style: none;
    }
  }
  .card-table {
    overflow-y: auto;
  }
}
