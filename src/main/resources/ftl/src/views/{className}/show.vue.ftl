<#include "/abstracted/common.ftl">
<#if !this.entityFeature.show || !this.entityFeature.list>
    <@call this.skipCurrent()/>
</#if>
<template>
  <el-dialog title="查看${this.title}" :visible.sync="formVisible">
    <el-form ref="dataForm" :model="form"
             label-position="left" size="small"
             label-width="100px" style="width: 400px; margin-left:50px;">
<#list this.showFields as id,field>
      <el-form-item label="${field.fieldDesc}">
        <span class="form-item-show">
    <#if field.dicType??>
        <#assign const = findConst(field.dicType)>
        <@justCall importEnums.add(const)/>
        <#assign constName = const.constName?uncapFirst>
          {{ form.${field.jfieldName} | findEnumLabel(enums.${constName}) }}
    <#else>
          {{ form.${field.jfieldName} }}
    </#if>
        </span>
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
<#if !importEnums.isEmpty()>
import enums from '@/utils/enums'
</#if>

export default {
  name: '${this.classNameUpper}Show',
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
<#if !importEnums.isEmpty()>
  filters: {
    findEnumLabel: enums.findEnumLabel
  },
</#if>
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
