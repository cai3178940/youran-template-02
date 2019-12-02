<#-- 功能简介：表格页面数据预处理 -->
<#include "/abstracted/common.ftl">
<#--表格是否可选择-->
<#assign tableSelect=this.entityFeature.deleteBatch/>
<#--表格是否可排序-->
<#assign tableSort=this.listSortFields?? && this.listSortFields?size &gt; 0/>
<#--表格是否需要操作列-->
<#assign tableOperate=this.entityFeature.show || this.entityFeature.update || this.entityFeature.delete/>
