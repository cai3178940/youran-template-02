<#include "/abstracted/common.ftl">
<#if !this.entityFeature.show || !this.entityFeature.list>
    <@call this.skipCurrent()/>
</#if>
<template>
  <el-dialog title="查看${this.title}" :visible.sync="formVisible">
    <el-form ref="dataForm" :model="form"
             label-position="left"
             label-width="100px" style="width: 400px; margin-left:50px;">
<#list this.showFields as id,field>
      <el-form-item label="${field.fieldDesc}">
        <span class="form-item-show">{{ form.${field.jfieldName} }}</span>
      </el-form-item>
</#list>
    </el-form>
    <div slot="footer" class="dialog-footer">
      <el-button @click="formVisible = false">
        取消
      </el-button>
    </div>
  </el-dialog>
</template>

<script>
import ${this.className}Api from '@/api/${this.className}'

export default {
  name: '${this.classNameUpper}Show',
  data() {
    return {
      form: {
<@removeLastComma>
    <#list this.showFields as id,field>
        ${field.jfieldName}: null,
    </#list>
</@removeLastComma>
      },
      formVisible: false
    }
  },
  methods: {
    /**
     * 打开查看表单
     */
    handleShow(${this.id}) {
      ${this.className}Api.fetchById(${this.id})
        .then(data => {
          this.form = data
          this.formVisible = true
        })
    }
  }
}
</script>
