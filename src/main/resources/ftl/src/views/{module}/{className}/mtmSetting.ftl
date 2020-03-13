<#include "/abstracted/common.ftl">
<#include "/abstracted/mtmCascadeExtsForShow.ftl">
<#if !this.entityFeature.list>
    <@call this.skipCurrent()/>
</#if>
<#list this.holds! as otherEntity,mtm>
    <#assign entityFeature=mtm.getEntityFeature(this.entityId)>
    <#if !entityFeature.set>
        <#continue>
    </#if>
    <#assign otherCName=otherEntity.className>
    <#assign othercName=lowerFirstWord(otherEntity.className)>
    <#assign otherId=otherEntity.pkField.jfieldName>
    <#--用于判断是否存在级联扩展-->
    <#assign index=getMtmCascadeEntityIndexForShow(otherEntity.entityId)>
    <#--定义代码内容-->
    <#assign code>
<template>
  <el-dialog title="配置${otherEntity.title}" :visible.sync="formVisible">
    <el-form ref="dataForm" :model="form"
             label-position="left" size="small"
             label-width="100px" style="width: 400px; margin-left:50px;">
      <el-form-item label="${otherEntity.title}">
        <el-select v-model="form.${othercName}List"
                   style="width:100%;" placeholder="请选择"
                   filterable clearable multiple>
          <el-option v-for="item in options.${othercName}"
                     :key="item.key"
                     :label="item.value"
                     :value="item.key">
          </el-option>
        </el-select>
      </el-form-item>
    </el-form>
    <div slot="footer" class="dialog-footer">
      <el-button @click="formVisible = false">
        取消
      </el-button>
      <el-button type="primary"
                 @click="doUpdate()">
        确认
      </el-button>
    </div>
  </el-dialog>
</template>

<script>
${importApi(this.metaEntity)}
${importApi(otherEntity)}

function initFormBean() {
  const formBean = {
    ${this.id}: null,
    ${othercName}List: []
  }
  return formBean
}

export default {
  name: '${otherCName}Setting',
  data() {
    return {
      options: {
        ${othercName}: []
      },
      old: initFormBean(),
      form: initFormBean(),
      formVisible: false
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
     * 显示表单
     */
    handleShow(${this.id}) {
      ${othercName}Api.findOptions().then(data => { this.options.${othercName} = data })
      ${this.classNameLower}Api.fetch${otherCName}List(${this.id})
        .then(data => {
          this.old = {
            ${this.id}: ${this.id},
        <#if index &gt; -1>
            ${othercName}List: data.map(item => item.${otherId})
        <#else>
            ${othercName}List: data
        </#if>
          }
          this.resetForm()
          this.formVisible = true
        })
    },
    /**
     * 执行修改操作
     */
    doUpdate() {
      this.$refs['dataForm'].validate()
        .then(() => ${this.classNameLower}Api.set${otherCName}(this.form.${this.id}, this.form.${othercName}List))
        .then(data => {
          this.formVisible = false
          this.$common.showMsg('success', '配置成功')
          this.$emit('updated', data)
        })
    }
  }
}
</script>

    </#assign>
    <#--往当前目录输出额外代码文件-->
    <@justCall this.writeAdditionalFile("${othercName}Setting.vue",code)/>
</#list>
<#--不需要输出当前文件-->
<@call this.skipCurrent()/>
