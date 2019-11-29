import defaultSettings from '@/settings'

const title = defaultSettings.title || 'Vue Admin Template'

export default function getPageTitle(pageTitle) {
  if (pageTitle) {
    return `${r'$'}{pageTitle} - ${r'$'}{title}`
  }
  return `${r'$'}{title}`
}
