<#-- 调用函数，如果存在输出则打印 -->
<#macro call func><#if func??>${func}</#if></#macro>
<#-- 仅调用函数，不打印 -->
<#macro justCall func></#macro>

<#-- 将当前model赋值给this变量 -->
<#assign this = .data_model>

<#-- 初始需要导入的枚举列表 -->
<#assign importEnums = CommonTemplateFunction.createHashSet()>

<#-- 移除最后一个逗号 -->
<#macro removeLastComma>
<#local content><#nested></#local>
${CommonTemplateFunction.removeLastComma(content)}</#macro>

<#-- 根据常量名查找常量 -->
<#function findConst constName>
    <#list this.metaConsts as const>
        <#if const.constName == constName>
            <#return const>
        </#if>
    </#list>
</#function>
