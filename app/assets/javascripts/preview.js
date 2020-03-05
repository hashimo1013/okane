$(function(){
  // プレビュー用のimgタグを生成
  const buildImg = (url)=> {
    const html = `<img src="${url}" width="600px" height="600px">`;
    return html;
  }
// 画像を選択
  $('#money_image').change(function(e){
    console.log(333);
    const file = e.target.files[0];
    const blobUrl = window.URL.createObjectURL(file);
    $('#previews').append(buildImg(blobUrl));
  })

})