<#include "/abstracted/common.ftl">
<#include "/abstracted/commonForChart.ftl">
<template>
  <div class="chart-container">
    <three-table height="100%" width="100%" />
  </div>
</template>

<script>
import ${this.chartName} from '@/components/Charts/${this.chartName}'

export default {
  name: '${this.chartName}View',
  components: { ${this.chartName} }
}
</script>

<style scoped>
  .chart-container{
    position: relative;
    width: 100%;
    height: calc(100vh - 84px);
  }
</style>

