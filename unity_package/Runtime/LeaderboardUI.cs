using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace SimpleLeaderboardPro
{
    public class LeaderboardUI : MonoBehaviour
    {
        [Header("Tab Buttons")]
        public Button btnToday;
        public Button btnWeekly;
        public Button btnMonthly;
        public Button btnAll;

        [Header("List Area")]
        public Transform listContainer;
        public GameObject rankItemPrefab;
        public Text statusText;

        [Header("Demo Submit Form")]
        public InputField inputName;
        public InputField inputScore;
        public Button btnSubmit;
        public Text btnSubmitText;

        [Header("Demo Options")]
        [Tooltip("開発テスト確認用の送信フォームを表示するか（ゲーム本番ではOFFにします）")]
        public bool showDemoForm = true;

        [Header("Main Panel for Pop Animation")]
        public RectTransform mainPanel;

        private string currentPeriod = "all";

        private void Start()
        {
            if (btnSubmit != null && btnSubmit.transform.parent != null)
            {
                btnSubmit.transform.parent.gameObject.SetActive(showDemoForm);
            }

            if (LeaderboardManager.Instance != null)
            {
                LeaderboardManager.Instance.OnLeaderboardLoaded += HandleLeaderboardLoaded;
                LeaderboardManager.Instance.OnScoreSubmitted += HandleScoreSubmitted;
            }

            if (btnToday != null) btnToday.onClick.AddListener(() => SwitchTab("today", btnToday));
            if (btnWeekly != null) btnWeekly.onClick.AddListener(() => SwitchTab("weekly", btnWeekly));
            if (btnMonthly != null) btnMonthly.onClick.AddListener(() => SwitchTab("monthly", btnMonthly));
            if (btnAll != null) btnAll.onClick.AddListener(() => SwitchTab("all", btnAll));

            if (btnSubmit != null) btnSubmit.onClick.AddListener(() => OnSubmitClicked());

            // ポップインアニメーション
            if (mainPanel != null)
            {
                StartCoroutine(PopInRoutine());
            }

            SwitchTab("all", btnAll);
        }

        private IEnumerator PopInRoutine()
        {
            mainPanel.localScale = new Vector3(0.7f, 0.7f, 1f);
            float elapsed = 0f;
            float duration = 0.3f;
            while (elapsed < duration)
            {
                elapsed += Time.deltaTime;
                float t = elapsed / duration;
                // バウンスイーズに近いシンプルなイージング
                float scale = Mathf.Lerp(0.7f, 1.05f, Mathf.Sin(t * Mathf.PI * 0.8f));
                if (t >= 1f) scale = 1.0f;
                mainPanel.localScale = new Vector3(scale, scale, 1f);
                yield return null;
            }
            mainPanel.localScale = Vector3.one;
        }

        private void SwitchTab(string period, Button activeBtn)
        {
            currentPeriod = period;
            if (statusText != null)
            {
                statusText.text = "Loading...";
                statusText.gameObject.SetActive(true);
            }

            // タブカラー調整
            Button[] btns = { btnToday, btnWeekly, btnMonthly, btnAll };
            foreach (var b in btns)
            {
                if (b == null) continue;
                var img = b.GetComponent<Image>();
                if (img != null)
                {
                    img.color = (b == activeBtn) ? new Color(1f, 1f, 1f, 1f) : new Color(1f, 1f, 1f, 0.5f);
                }
            }

            // リストクリア
            ClearList();

            if (LeaderboardManager.Instance != null)
            {
                LeaderboardManager.Instance.FetchLeaderboard(period);
            }
        }

        private void ClearList()
        {
            if (listContainer == null) return;
            foreach (Transform child in listContainer)
            {
                Destroy(child.gameObject);
            }
        }

        private void HandleLeaderboardLoaded(string period, List<ScoreItem> data)
        {
            if (period != currentPeriod) return;

            if (statusText != null) statusText.gameObject.SetActive(false);
            ClearList();

            if (data == null || data.Count == 0)
            {
                if (statusText != null)
                {
                    statusText.text = "No scores yet! Be the first challenger!";
                    statusText.gameObject.SetActive(true);
                }
                return;
            }

            foreach (var item in data)
            {
                if (rankItemPrefab == null || listContainer == null) continue;
                GameObject obj = Instantiate(rankItemPrefab, listContainer);
                RankItemUI itemUI = obj.GetComponent<RankItemUI>();
                if (itemUI != null)
                {
                    itemUI.Setup(item.rank, item.player_name, item.score);
                }
            }
        }

        private void OnSubmitClicked()
        {
            string playerName = (inputName != null) ? inputName.text : "Player";
            if (string.IsNullOrEmpty(playerName)) playerName = "Player_" + Random.Range(100, 999);

            int score = 1000;
            if (inputScore != null && int.TryParse(inputScore.text, out int parsed))
            {
                score = parsed;
            }

            if (btnSubmit != null) btnSubmit.interactable = false;
            if (btnSubmitText != null) btnSubmitText.text = "Sending...";

            string playerId = "unity_user_" + playerName.GetHashCode();

            if (LeaderboardManager.Instance != null)
            {
                LeaderboardManager.Instance.SubmitScore(playerId, playerName, score);
            }
        }

        private void HandleScoreSubmitted(bool success, string msg)
        {
            if (btnSubmit != null) btnSubmit.interactable = true;
            if (btnSubmitText != null) btnSubmitText.text = "SUBMIT!";

            if (statusText != null)
            {
                statusText.text = success ? "🎉 Score submitted!" : $"Error: {msg}";
                statusText.gameObject.SetActive(true);
            }

            if (success)
            {
                SwitchTab(currentPeriod, GetButtonByPeriod(currentPeriod));
            }
        }

        private Button GetButtonByPeriod(string p)
        {
            switch (p)
            {
                case "today": return btnToday;
                case "weekly": return btnWeekly;
                case "monthly": return btnMonthly;
                default: return btnAll;
            }
        }

        private void Update()
        {
            AdjustResponsiveScale();
        }

        private void AdjustResponsiveScale()
        {
            if (mainPanel == null) return;
            Canvas canvas = mainPanel.GetComponentInParent<Canvas>();
            if (canvas == null) return;
            RectTransform canvasRect = canvas.GetComponent<RectTransform>();
            if (canvasRect == null) return;

            float vpWidth = canvasRect.rect.width;
            float vpHeight = canvasRect.rect.height;
            float panelWidth = 580f;
            float panelHeight = 620f;

            float scaleX = (vpWidth * 0.92f) / panelWidth;
            float scaleY = (vpHeight * 0.88f) / panelHeight;
            float targetScale = Mathf.Min(scaleX, scaleY);

            mainPanel.localScale = new Vector3(targetScale, targetScale, 1f);
        }

        private void OnDestroy()
        {
            if (LeaderboardManager.Instance != null)
            {
                LeaderboardManager.Instance.OnLeaderboardLoaded -= HandleLeaderboardLoaded;
                LeaderboardManager.Instance.OnScoreSubmitted -= HandleScoreSubmitted;
            }
        }
    }
}
