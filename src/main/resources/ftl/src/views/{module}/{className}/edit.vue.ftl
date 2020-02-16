<#include "/abstracted/common.ftl">
<#include "/abstracted/mtmCascadeExtsForShow.ftl">
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
        <el-input-number v-model="form.${field.jfieldName}" style="width:100%;" controls-position="right"></el-input-number>
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
                    :label="item.value">{{ item.label }}</el-radio>
        </#if>
        </el-radio-group>
    <#elseIf field.editType == EditType.SELECT.getValue()>
        <el-select v-model="form.${field.jfieldName}"
                   style="width:100%;" placeholder="请选择"
                   filterable clearable>
        <#if field.foreignKey>
            <@justCall importOtherEntitys.add(field.foreignEntity)/>
          <el-option v-for="item in options.${field.foreignEntity.className?uncapFirst}"
                     :key="item.key"
                     :label="item.value"
                     :value="item.key">
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
        </#if>
        </el-select>
    </#if>
      </el-form-item>
</#list>
<#list this.holds! as otherEntity,mtm>
    <#assign entityFeature=mtm.getEntityFeature(this.entityId)>
    <#if entityFeature.withinEntity>
        <#assign othercName=otherEntity.className?uncapFirst>
        <@justCall importOtherEntitys.add(otherEntity)/>
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
    </#if>
</#list>
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
import ${this.className}Api from '@/api/${this.module?? ? then(this.module+"/","")}${this.className}'
<#if !importOtherEntitys.isEmpty()>
    <#list importOtherEntitys as foreignEntity>
        <#if foreignEntity == this.metaEntity><#break></#if>
        <#assign foreignClassName = foreignEntity.className?uncapFirst>
import ${foreignClassName}Api from '@/api/${foreignEntity.module?? ? then(foreignEntity.module+"/","")}${foreignClassName}'
    </#list>
</#if>
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
    <#list this.holds! as otherEntity,mtm>
        <#assign entityFeature=mtm.getEntityFeature(this.entityId)>
        <#if entityFeature.withinEntity>
            <#assign othercName=otherEntity.className?uncapFirst>
    ${othercName}List: [],
        </#if>
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
        ${const.constName?uncapFirst}: enums.get${const.constName}(),
        </#list>
    </@removeLastComma>
      },
</#if>
<#if !importOtherEntitys.isEmpty()>
      options: {
    <@removeLastComma>
        <#list importOtherEntitys as foreignEntity>
        ${foreignEntity.className?uncapFirst}: [],
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
        ${field.jfieldName}: [
        <@removeLastComma>
            <#if field.notNull>
          { required: true, message: '请输入${field.fieldDesc}', trigger: '${getRuleTrigger(field)}' },
            </#if>
            <#if (field.editType == EditType.TEXT.getValue()
              || field.editType == EditType.TEXTAREA.getValue())
              && field.fieldLength &gt; 0>
          { max: ${field.fieldLength}, message: '长度不能超过${field.fieldLength}个字符', trigger: 'blur' },
            </#if>
        </@removeLastComma>
        ],
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
<#if !importOtherEntitys.isEmpty()>
    <@removeLastComma>
        <#list importOtherEntitys as foreignEntity>
            <#assign foreignClassName = foreignEntity.className?uncapFirst>
      ${foreignClassName}Api.findOptions().then(data => { this.options.${foreignClassName} = data })
        </#list>
    </@removeLastComma>
</#if>
      ${this.className}Api.fetchById(${this.id})
        .then(data => {
<#if mtmCascadeEntitiesForShow?size &gt; 0>
          this.old = Object.assign({}, data, {
    <@removeLastComma>
        <#list mtmCascadeEntitiesForShow as otherEntity>
            <#assign othercName=otherEntity.className?uncapFirst>
            <#assign pkField=otherEntity.pkField>
            ${othercName}List: data.${othercName}List ? data.${othercName}List.map(t => t.${pkField.jfieldName}) : [],
        </#list>
    </@removeLastComma>
          })
<#else>
          this.old = data
</#if>
          this.resetForm()
          this.formVisible = true
          this.$nextTick(() => {
            this.$refs['dataForm'].clearValidate()
          })
        })
    },
    /**
     * 执行修改操作
     */
    doUpdate() {
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
