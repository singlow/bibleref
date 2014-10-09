$ = jQuery

patterns = {
  "Genesis": "Gen(esis)?"
  "Exodus": "Ex(odus)?"
  "Leviticus": "Lev(iticus)?"
  "Numbers": "Num(bers)?"
  "Deuteronomy": "Deut?(eronomy)?"
  "Joshua": "Jos?(hua)?"
  "Judges": "Jud(ges)?"
  "Ruth": "Ru(th?)?"
  "1 Samuel": "(1(st)|I) ?Sa(m(uel)?)?"
  "2 Samuel": "(2(nd)|II) ?Sa(m(uel)?)?"
  "1 Kings": "(1(st)|I)? ?Ki(ngs)?"
  "2 Kings": "(2(nd)|II)? ?Ki(ngs)?"
  "1 Chronicles": "(1(st)?|I) ?Chr(on(icles)?)?"
  "2 Chronicles": "(2(nd)?|II) ?Chr(on(icles)?)?"
  "Ezra": "Ez(ra)?"
  "Nehemiah": "Ne(h(emiah)?)?"
  "Esther": "Es(t(her)?)?"
  "Job": "Jo?b"
  "Psalms": "Ps(alms?)?"
  "Proverbs": "Pro(v(erbs)?)?"
  "Ecclesiastes": "Ecc(lesiastes)?"
  "Song of Solomon": "(Sg|Song of Songs|Song of Sol(omon)?)"
  "Isaiah": "Is(a(iah)?)?"
  "Jeremiah": "Je(r(emiah)?)?"
  "Lamentations": "La(m(entations)?)?"
  "Ezekiel": "Ez(e(k(iel)?)?)?"
  "Daniel": "Da(n(iel)?)?"
  "Hoseah": "Ho(s(ea)?)?"
  "Joel": "(Joel|Jl)"
  "Amos": "Am(os)?"
  "Obadiah": "Ob(a(d(iah)?)?)?"
  "Jonah": "Jon(ah)?"
  "Micah": "Mi(c(ah)?)?"
  "Nahum": "Na(h(um)?)?"
  "Habakkuk": "(Ha(b(akkuk)?)?|Hb)"
  "Zephaniah": "Zep(haniah)?"
  "Haggai": "Ha?g(gai)?"
  "Zechariah": "Zec(h(ariah)?)?"
  "Malachi": "Mal(achi)?"
  "Matthew": "Ma?t(t(hew)?)?"
  "Mark": "M(ar)?k"
  "Luke": "(Luke|Lk|Lu)"
  "John": "(John|Jn)"
  "Acts": "(Acts|Ac|Act)"
  "Romans": "Rom?(ans)?"
  "1 Corinthians": "(1(st)?|I) ?Cor(inthians)?"
  "2 Corinthians": "(2(nd)?|II) ?Cor(inthians)?"
  "Galatians": "Ga(l(atians)?)?"
  "Ephesians": "Eph(esians)?"
  "Philippians": "Phil(ippians)?"
  "Colossians": "Col(ossians)?"
  "1 Thessalonians": "(1(st)?|I) ?Thess(alonians)?"
  "2 Thessalonians": "(2(nd)?|II) ?Thess(alonians)?"
  "1 Timothy": "(1(st)?|I) ?Tim(othy)?"
  "2 Timothy": "(2(nd)?|II) ?Tim(othy)?"
  "Titus": "Tit(us)?"
  "Philemon": "(Philem(on)?|Phlm)"
  "Hebrews": "Heb(rews)?"
  "James": "Ja(me)?s"
  "1 Peter": "(1(st)?|I) ?(Pet(er)?|Pt)"
  "2 Peter": "(2(nd)?|II) ?(Pet(er)?|Pt)"
  "1 John": "(1(st)?|I) ?(John|Jn)"
  "2 John": "(2(nd)?|II) ?(John|Jn)"
  "3 John": "(3(rd)?|III) ?(John|Jn)"
  "Jude": "(Jude|Jud|Jd)"
  "Revelation": "Re(v(elation)?)?"
}

normalizeBookName = (t)->
  t = t.replace(RegExp(pat+"\\.?\\b"), name) for name, pat of patterns
  return t

allBooks = '(' + (pattern for book, pattern of patterns).join('|') + ')'
allBooksRegEx = RegExp('('+allBooks+'\.? [0-9]{1,3}([0-9 -:;,]+[0-9])?)', 'gi')

replacement = (match)->
  stdname = normalizeBookName(match)
  return "<a href=\"http://www.biblegateway.com/passage/?search=#{stdname}&version=nasb\" data-bibleref=\"#{stdname}\">#{match}</a>"

$(document).ready ->

  $("p,li,dd,dt,td,q,blockquote").html (index, html)->
    return html.replace(allBooksRegEx, replacement)

  $('body').on 'click blur', 'a[data-bibleref]', (e)->
    e.preventDefault()
    that = this

    $('a[data-bibleref][aria-describedby]').not(e.target).popover('hide')

    return if $(this).data('bibletext')
    
    $(that).css("cursor", "progress")
    $.ajax
      url:'http://getbible.net/json'
      dataType: 'jsonp'
      jsonp: 'getbible'
      data: 'v=nasb&p='+$(this).data('bibleref')
    .then (data)->
      html = ''
      if data.book?
        for book in data.book
          html += '<h3>'+book.book_name+' '+book.chapter_nr+'</h3>'
          for own key, verse of book.chapter
            html += '<p><b>'+key+'</b> ' + verse.verse + '</p>'
        $(that).data("bibletext", html)
        $(that).popover
          html: true
          content: html
          placement: 'auto'
          trigger: 'focus click'
        .popover('show')
      else
        html = "<div class='alert alert-warning'>Could not retrieve bible text.</div>"
        $(that).data("bibletext", html)
        $(that).popover
          html: true
          title: 'Error'
          content: html
          placement: 'auto'
          trigger: 'focus click'
        .popover('show')
    .fail ->
      html = "<div class='alert alert-warning'>Could not retrieve bible text.</div>"
      $(that).data("bibletext", html)
      $(that).popover
        html: true
        title: 'Error'
        content: html
        placement: 'auto'
        trigger: 'focus click'
      .popover('show')
    .always ->
      $(that).css("cursor", "pointer")

