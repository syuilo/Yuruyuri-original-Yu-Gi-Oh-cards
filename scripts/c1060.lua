-- 大室撫子
-- ①：自分フィールド上に「大室櫻子」が表側表示で存在する場合、このカードは手札から特殊召喚することができる。
-- ②：このカードが特殊召喚に成功した時、フィールド上のカード1枚を選択し持ち主の手札に戻すことができる。
-- ③：このカードが相手によって破壊された時、自分の墓地・デッキから「大室花子」を特殊召喚できる。

function c1060.initial_effect(c)

	-- special summon
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1060, 0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c1060.e1condition)
	c:RegisterEffect(e1)

	-- tohand
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1060, 1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c1060.e2target)
	e2:SetOperation(c1060.e2operation)
	c:RegisterEffect(e2)

	-- special summon
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1060, 3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c1060.e3condition)
	e3:SetTarget(c1060.e3target)
	e3:SetOperation(c1060.e3operation)
	c:RegisterEffect(e3)

end

-- 櫻子フィルター
function c1060.e1spfilter(c)
	-- 表側表示(=IsFaceup)かつ櫻子(=1050)か
	return c:IsFaceup() and c:IsCode(1050)
end

function c1060.e1condition(e, c)
	if c == nil then return true end
	return Duel.GetLocationCount(c:GetControler(), LOCATION_MZONE) > 0 and
		Duel.IsExistingMatchingCard(c1060.e1spfilter, c:GetControler(), LOCATION_ONFIELD, 0, 1, nil)
end

-- <誰がなにを対象に発動するのか>
function c1060.e2target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	if chk == 0 then return Duel.IsExistingTarget(Card.IsAbleToHand, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
	local g = Duel.SelectTarget(tp, Card.IsAbleToHand, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end

-- <効果の内容>
function c1060.e2operation(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc, nil, REASON_EFFECT)
	end
end

function c1060.e3condition(e, tp, eg, ep, ev, re, r, rp)
	return rp ~= tp and e:GetHandler():GetPreviousControler() == tp
end

function c1060.e3filter(c, e, tp)
	return c:IsCode(1070) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function c1060.e3target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_DECK+LOCATION_GRAVE) and chkc:IsControler(tp) and c1060.e3filter(chkc, e, tp) end
	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsExistingTarget(c1060.e3filter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, nil, e, tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g = Duel.SelectTarget(tp,c1060.e3filter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function c1060.e3operation(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
	end
end
