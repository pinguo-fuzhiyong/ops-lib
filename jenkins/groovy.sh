import groovy.json.JsonSlurper
def recurse 
def versionArraySort = { a1, a2 -> 
    def headCompare = a1[0] <=> a2[0] 
    if (a1.size() == 1 || a2.size() == 1 || headCompare != 0) { 
        return headCompare 
    } else { 
        return recurse(a1[1..-1], a2[1..-1]) 
    } 
} 
// fool Groovy to understand recursive closure 
recurse = versionArraySort
def versionStringSort = { s1, s2 -> 
    def nums = { it.tokenize('.').collect{ it.toInteger() } } 
    versionArraySort(nums(s1), nums(s2)) 
}
try {
    List<String> artifacts = new ArrayList<String>()
    def cmdapp = "/root/scripts/jenkinstag"
    def repo = "reserve/umscloud-server"
    def artifactsObjectRaw = ["${cmdapp}","get","tag","--repoName","${repo}"].execute().text
    def jsonSlurper = new JsonSlurper()
    def artifactsJsonObject = jsonSlurper.parseText(artifactsObjectRaw)
    def dataArray = artifactsJsonObject.data
    for(item in dataArray){
        if (item.IsMetadata == false)
        artifacts.add(item.Text)
    } 
    return artifacts.sort(versionStringSort).reverse()
} catch (Exception e) {
    print "There was a problem fetching the artifacts" + e
}