<#include "/abstracted/common.ftl">
<#if !this.entityFeature.save || !this.entityFeature.list>
    <@call this.skipCurrent()/>
</#if>
<template>
  <el-dialog title="新建${this.title}" :visible.sync="formVisible">
    <el-form ref="dataForm" :rules="formRules" :model="form"
             label-position="left"
             label-width="100px" style="width: 400px; margin-left:50px;">
<#list this.insertFields as id,field>
      <el-form-item label="${field.fieldDesc}" prop="${field.jfieldName}">
        <el-input v-model="form.${field.jfieldName}" />
      </el-form-item>
</#list>
    </el-form>
    <div slot="footer" class="dialog-footer">
      <el-button @click="formVisible = false">
        取消
      </el-button>
      <el-button type="primary"
                 @click="createData()">
        确认
      </el-button>
    </div>
  </el-dialog>
</template>

<script>
import ${this.className}Api from '@/api/${this.className}'

function initFormBean() {
  const formBean = {
<@removeLastComma>
    <#list this.insertFields as id,field>
    ${field.jfieldName}: null,
    </#list>
</@removeLastComma>
  }
  return formBean
}

export default {
  name: '${this.classNameUpper}Add',
  data() {
    return {
      form: initFormBean(),
      formVisible: false,
      formRules: {
<@removeLastComma>
    <#list this.insertFields as id,field>
        name: [{
        <#if field.notNull>
          required: true,
        </#if>
          message: '请输入${field.fieldDesc}',
          trigger: 'blur'
        }],
    </#list>
</@removeLastComma>
      }
    }
  },
  methods: {
    /**
     * 重置表单
     */
    resetForm() {
      this.form = initFormBean()
    },
    /**
     * 打开新建表单
     */
    handleCreate() {
      this.resetForm()
      this.formVisible = true
    },
    /**
     * 执行新建操作
     */
    createData() {
      this.$refs['dataForm'].validate()
        .then(() => ${this.className}Api.create(this.form))
        .then(data => {
          this.formVisible = false
          this.$common.showMsg('success', '创建成功')
          this.$emit('created', data)
        })
    }
  }
}
</script>
