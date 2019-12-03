<#include "/abstracted/common.ftl">
<#list this.metaConsts>
    <#items as const>
        <#assign isString = const.constType==MetaConstType.STRING>
        <#assign constName = const.constName?uncapFirst>
const ${constName} = new Map()
        <#list const.detailList as detail>
${constName}.set(<#if isString>'${detail.detailValue}'<#else>${detail.detailValue}</#if>, '${detail.detailRemark}')
        </#list>

    </#items>
<#else>
    <@call this.skipCurrent()/>
</#list>
export {
<@removeLastComma>
    <#list this.metaConsts as const>
  ${const.constName?uncapFirst},
    </#list>
</@removeLastComma>
}
