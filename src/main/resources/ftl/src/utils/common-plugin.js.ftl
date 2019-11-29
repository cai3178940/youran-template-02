export default {
  install(Vue, options) {
    Vue.prototype.$common = {
      confirm(msg) {
        return Vue.prototype.$confirm(msg, '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        })
      },
      showNotify(type, title, msg) {
        let duration = 4500
        if (type === 'error') {
          duration = 10000
        }
        return Vue.prototype.$notify({
          title: title,
          type: type,
          message: msg,
          duration
        })
      },
      // 打印常用异常
      showNotifyError(error) {
        // 表单校验异常
        if (error === false) {
          return this.showNotify('error', '出错了', '表单校验失败')
        }
        // 程序指定字符串异常信息
        if ((typeof error === 'string' && error.constructor === String)) {
          // 如果是确认窗口点击取消按钮，则不报任何错
          if (error === 'cancel') {
            return
          }
          return this.showNotify('error', '出错了', error)
        }
        if ((typeof error === 'object')) {
          if (error.constructor === Error) {
            if (error.response) {
              if (error.response.status >= 400) {
                if (error.response.data) {
                  return this.showErrorVO(error.response.data)
                } else {
                  return this.showErrorVO(error)
                }
              }
            }
            if (error.message) {
              return this.showNotify('error', '出错了', error.message)
            }
          }
          // 远程200返回结果中的异常
          if (error.code && error.code !== '0') {
            return this.showErrorVO(error)
          }
        }
        // 未知异常
        return this.showNotify('error', '出错了', '')
      },

      showErrorVO(errorVO) {
        return this.showNotify('error', '出错了', errorVO.message)
      },

      showMsg(type, msg) {
        Vue.prototype.$message({
          message: msg,
          type: type
        })
      },
      // 校验服务器返回结果
      checkResult(response) {
        return new Promise((resolve, reject) => {
          if (response.status >= 200 && response.status < 300) {
            return resolve(response.data)
          } else {
            return reject(new Error(response.data))
          }
        })
      }
    }
  }
}
