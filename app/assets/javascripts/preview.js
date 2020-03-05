$(function(){
  // プレビュー用のimgタグを生成
  const buildImg = (url)=> {
    const html = `<img src="${url}" width="600px" height="600px" id=previewImage >`;
    return html;
  }
// 画像を選択
  $('#money_image').change(function(e){
    const file = e.target.files[0];
    const blobUrl = window.URL.createObjectURL(file);
    if ($('#previewImage').length) {
      $('#previewImage').attr("src", blobUrl);
    } else {
    $('#preview').append(buildImg(blobUrl));
    }
  })

})