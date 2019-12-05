<#include "/abstracted/common.ftl">
<#list this.metaConsts>
    <#items as const>
        <#assign isString = const.constType==MetaConstType.STRING>
function get${const.constName}() {
  return {
        <@removeLastComma>
            <#list const.detailList as detail>
    '${detail.detailName}': {
      value: <#if isString>'${detail.detailValue}'<#else>${detail.detailValue}</#if>,
      label: '${detail.detailRemark}'
    },
            </#list>
        </@removeLastComma>
  }
}

    </#items>
<#else>
    <@call this.skipCurrent()/>
</#list>
export default {
<#list this.metaConsts as const>
  get${const.constName},
</#list>
  findEnumLabel(value, enums) {
    for (const key in enums) {
      const item = enums[key]
      if (item.value === value) {
        return item.label
      }
    }
    return ''
  }
}
