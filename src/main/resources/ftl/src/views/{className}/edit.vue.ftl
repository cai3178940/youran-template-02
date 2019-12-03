<#include "/abstracted/common.ftl">
<#if !this.entityFeature.update || !this.entityFeature.list>
    <@call this.skipCurrent()/>
</#if>
<template>
  <el-dialog title="编辑${this.title}" :visible.sync="formVisible">
    <el-form ref="dataForm" :rules="formRules" :model="form"
             label-position="left"
             label-width="100px" style="width: 400px; margin-left:50px;">
<#list this.updateFields as id,field>
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
                 @click="updateData()">
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
    ${this.pk.jfieldName}: null,
    <#list this.updateFields as id,field>
    ${field.jfieldName}: null,
    </#list>
</@removeLastComma>
  }
  return formBean
}

export default {
  name: '${this.classNameUpper}Edit',
  data() {
    return {
      old: initFormBean(),
      form: initFormBean(),
      formVisible: false,
      formRules: {
<@removeLastComma>
    <#list this.updateFields as id,field>
        ${field.jfieldName}: [{
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
      for (const key in initFormBean()) {
        this.form[key] = this.old[key]
      }
    },
    /**
     * 打开编辑表单
     */
    handleUpdate(${this.id}) {
      ${this.className}Api.fetchById(${this.id})
        .then(data => {
          this.old = data
          this.resetForm()
          this.formVisible = true
        })
    },
    /**
     * 执行修改操作
     */
    updateData() {
      this.$refs['dataForm'].validate()
        .then(() => ${this.className}Api.update(this.form))
        .then(data => {
          this.formVisible = false
          this.$common.showMsg('success', '修改成功')
          this.$emit('updated', data)
        })
    }
  }
}
</script>
