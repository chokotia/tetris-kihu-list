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
                    item.className = 'p-3 border-bottom d-flex justify-content-between align-items-center';
                    
                    const link = document.createElement('a');
                    link.href = url;
                    link.textContent = title;
                    link.target = '_blank';
                    link.className = 'text-decoration-none text-primary';
                    
                    // 閲覧回数を取得
                    const viewCount = localStorage.getItem(title) || 0;
                    const viewCountSpan = document.createElement('span');
                    viewCountSpan.className = 'badge bg-secondary';
                    viewCountSpan.textContent = `閲覧回数: ${viewCount}`;
                    
                    // リンククリック時の閲覧回数更新
                    link.addEventListener('click', () => {
                        const currentCount = parseInt(localStorage.getItem(title) || 0);
                        localStorage.setItem(title, currentCount + 1);
                        viewCountSpan.textContent = `閲覧回数: ${currentCount + 1}`;
                    });
                    
                    item.appendChild(link);
                    item.appendChild(viewCountSpan);
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