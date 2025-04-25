document.addEventListener('DOMContentLoaded', function() {
    fetch('kihu-list.txt')
        .then(response => response.text())
        .then(data => {
            const kihuList = document.getElementById('kihu-list');
            const lines = data.split('\n').filter(line => line.trim());
            
            lines.forEach(line => {
                const [title, url] = line.split(' ');
                if (title && url) {
                    const item = document.createElement('div');
                    item.className = 'p-3 border-bottom';
                    
                    const link = document.createElement('a');
                    link.href = url;
                    link.textContent = title;
                    link.target = '_blank';
                    link.className = 'text-decoration-none text-primary';
                    
                    item.appendChild(link);
                    kihuList.appendChild(item);
                }
            });
        })
        .catch(error => {
            console.error('棋譜リストの読み込みに失敗しました:', error);
            const kihuList = document.getElementById('kihu-list');
            kihuList.innerHTML = '<div class="alert alert-danger">棋譜リストの読み込みに失敗しました。</div>';
        });
}); 