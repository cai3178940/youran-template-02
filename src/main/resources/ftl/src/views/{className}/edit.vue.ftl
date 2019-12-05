<#include "/abstracted/common.ftl">
<#if !this.entityFeature.update || !this.entityFeature.list>
    <@call this.skipCurrent()/>
</#if>
<template>
  <el-dialog title="编辑${this.title}" :visible.sync="formVisible">
    <el-form ref="dataForm" :rules="formRules" :model="form"
             label-position="left" size="small"
             label-width="100px" style="width: 400px; margin-left:50px;">
<#list this.updateFields as id,field>
      <el-form-item label="${field.fieldDesc}" prop="${field.jfieldName}">
    <#if field.editType == EditType.TEXT.getValue()>
        <el-input v-model="form.${field.jfieldName}"/>
    <#elseIf field.editType == EditType.TEXTAREA.getValue()>
        <el-input v-model="form.${field.jfieldName}" type="textarea" :rows="2"></el-input>
    <#elseIf field.editType == EditType.NUMBER.getValue()>
        <el-input-number v-model="form.${field.jfieldName}" controls-position="right"></el-input-number>
    <#elseIf field.editType == EditType.DATE.getValue()>
        <el-date-picker v-model="form.${field.jfieldName}" type="date" placeholder="选择日期"></el-date-picker>
    <#elseIf field.editType == EditType.DATETIME.getValue()>
        <el-date-picker v-model="form.${field.jfieldName}" type="datetime" placeholder="选择日期时间"></el-date-picker>
    <#elseIf field.editType == EditType.RADIO.getValue()>
        <el-radio-group v-model="form.${field.jfieldName}">
        <#if field.jfieldType == JFieldType.BOOLEAN.javaType>
          <el-radio :label="true">是</el-radio>
          <el-radio :label="false">否</el-radio>
        <#elseIf field.dicType??>
            <#assign const = findConst(field.dicType)>
            <@justCall importEnums.add(const)/>
            <#assign constName = const.constName?uncapFirst>
          <el-radio v-for="item in enums.${constName}"
                    :key="item.value"
                    :label="item.value">{{item.label}}</el-radio>
        <#else>
        </#if>
        </el-radio-group>
    <#elseIf field.editType == EditType.SELECT.getValue()>
        <el-select v-model="form.${field.jfieldName}"
                   style="width:100%;" filterable>
        <#if field.foreignKey>
          <el-option :label="'外键暂不支持'"
                     :value="1">
          </el-option>
        <#elseIf field.dicType??>
            <#assign const = findConst(field.dicType)>
            <@justCall importEnums.add(const)/>
            <#assign constName = const.constName?uncapFirst>
          <el-option v-for="item in enums.${constName}"
                     :key="item.value"
                     :label="item.label"
                     :value="item.value">
          </el-option>
        <#else>
        </#if>
        </el-select>
    <#else>
    </#if>
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
<#if !importEnums.isEmpty()>
import enums from '@/utils/enums'
</#if>

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
<#if !importEnums.isEmpty()>
      enums: {
    <@removeLastComma>
        <#list importEnums as const>
        ${const.constName?uncapFirst}: enums.get${const.constName}()
        </#list>
    </@removeLastComma>
      },
</#if>
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
