document.addEventListener('DOMContentLoaded', function() {
    // ステータスの定義
    const STATUS = {
        NOT_STARTED: { key: 'not_started', label: '未着手', class: 'bg-secondary' },
        IN_PROGRESS: { key: 'in_progress', label: '着手', class: 'bg-primary' },
        ON_HOLD: { key: 'on_hold', label: '保留', class: 'bg-warning text-dark' },
        COMPLETED: { key: 'completed', label: '完了', class: 'bg-success' }
    };
    
    const STATUS_ORDER = [STATUS.NOT_STARTED, STATUS.IN_PROGRESS, STATUS.ON_HOLD, STATUS.COMPLETED];
    
    // ステータスを取得する関数
    function getStatus(title) {
        const statusKey = localStorage.getItem(`status_${title}`) || STATUS.NOT_STARTED.key;
        return STATUS_ORDER.find(s => s.key === statusKey) || STATUS.NOT_STARTED;
    }
    
    // ステータスを保存する関数
    function setStatus(title, status) {
        localStorage.setItem(`status_${title}`, status.key);
    }
    
    // 次のステータスを取得する関数
    function getNextStatus(currentStatus) {
        const currentIndex = STATUS_ORDER.indexOf(currentStatus);
        return STATUS_ORDER[(currentIndex + 1) % STATUS_ORDER.length];
    }
    
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
                    
                    // 左側：タイトルリンク
                    const leftContainer = document.createElement('div');
                    leftContainer.className = 'd-flex align-items-center';
                    
                    const link = document.createElement('a');
                    link.href = url;
                    link.textContent = title;
                    link.target = '_blank';
                    link.className = 'text-decoration-none text-primary me-3';
                    
                    leftContainer.appendChild(link);
                    
                    // 右側：ステータスと閲覧回数
                    const rightContainer = document.createElement('div');
                    rightContainer.className = 'd-flex align-items-center gap-2';
                    
                    // ステータスバッジ（クリック可能）
                    const statusBadge = document.createElement('span');
                    statusBadge.className = 'badge';
                    statusBadge.style.cursor = 'pointer';
                    statusBadge.title = 'クリックでステータス変更';
                    
                    // 現在のステータスを取得して表示
                    let currentStatus = getStatus(title);
                    statusBadge.className = `badge ${currentStatus.class}`;
                    statusBadge.textContent = currentStatus.label;
                    
                    // ステータスクリック時の処理
                    statusBadge.addEventListener('click', (e) => {
                        e.stopPropagation(); // 親要素へのイベント伝播を防ぐ
                        const nextStatus = getNextStatus(currentStatus);
                        setStatus(title, nextStatus);
                        currentStatus = nextStatus;
                        statusBadge.className = `badge ${currentStatus.class}`;
                        statusBadge.textContent = currentStatus.label;
                    });
                    
                    // 閲覧回数バッジ
                    const viewCount = localStorage.getItem(`view_${title}`) || 0;
                    const viewCountSpan = document.createElement('span');
                    viewCountSpan.className = 'badge bg-info text-dark';
                    viewCountSpan.textContent = `閲覧: ${viewCount}回`;
                    
                    // リンククリック時の閲覧回数更新とステータス自動変更
                    link.addEventListener('click', () => {
                        // 閲覧回数の更新
                        const currentCount = parseInt(localStorage.getItem(`view_${title}`) || 0);
                        localStorage.setItem(`view_${title}`, currentCount + 1);
                        viewCountSpan.textContent = `閲覧: ${currentCount + 1}回`;
                        
                        // 未着手の場合のみ、着手に自動変更
                        if (currentStatus.key === STATUS.NOT_STARTED.key) {
                            setStatus(title, STATUS.IN_PROGRESS);
                            currentStatus = STATUS.IN_PROGRESS;
                            statusBadge.className = `badge ${currentStatus.class}`;
                            statusBadge.textContent = currentStatus.label;
                        }
                    });
                    
                    rightContainer.appendChild(statusBadge);
                    rightContainer.appendChild(viewCountSpan);
                    
                    item.appendChild(leftContainer);
                    item.appendChild(rightContainer);
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